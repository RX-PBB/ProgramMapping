#' globalsearch
#'
#' This function is the same as summarize_RXProgID_Data, but with a keyword parameter. We could consolidate into one function, but what to call it.
#' @param RXProgID names of the PBB databases to summarrize, set to NULL for all databases. Will exclude test databases
#' @param OrgProgID Specifiy an Org ProgID not the master list ID
#' @param DatabaseNames names of the PBB databases to summarrize, set to NULL for all databases. Will exclude test databases
#' @param keyword keyword to search program names and descriptions for
#' @param excludeZeroCost Should we exclude progrms that are zero cost.
#' @param db.settings Database user, host, pw
#' @export
#' @examples
#' data<-globalsearch(RXProgID=NULL,DatabaseNames=NULL,keyword='Fireworks')

globalsearch<-function(RXProgID,OrgProgID=NULL,DatabaseNames=NULL,keyword=NULL,excludeZeroCost=T,db.settings){

   
    data<-NULL

    #Even if we are not pulling by RX_ProgIDs get this info
    
        con <- dbConnect(MySQL(),
                           user=db.settings$user,
                           password=db.settings$pw,
                           host=db.settings$host,
                           dbname=db.settings$db_admin)


           statement<-paste("SELECT * FROM OrgInfo;",sep='')
           OrgInfo<-dbGetQuery(con,statement)
           
     
           if(!is.null(RXProgID)){
             statement<-paste("SELECT * FROM RX_ProgInfo WHERE RX_ProgID IN",create_IDstring(RXProgID),";",sep='')
             RX_ProgInfo<-dbGetQuery(con,statement)
           }
           if(is.null(RXProgID)){
             statement<-paste("SELECT * FROM RX_ProgInfo;",sep='')
             RX_ProgInfo<-dbGetQuery(con,statement)
             RXProgID<-RX_ProgInfo$RX_ProgID
          
        }
           
           
        dbDisconnect(con)
   

    if(is.null(DatabaseNames)){
    DatabaseNames<-sort(unique(OrgInfo[OrgInfo$IsTestOrg==0,'DatabaseName']))
    }



    for (i in 1:length(DatabaseNames)){
      #print(DatabaseNames[i])
      #Get ProgInfo for
      con <- dbConnect(MySQL(),
                       user=db.settings$user,
                       password=db.settings$pw,
                       host=db.settings$host,
                       dbname=DatabaseNames[i])

      #Do it this way if we are referencing the master list
      if(!is.null(RXProgID)){

         #If no keyword, then pull the prgorams by specified RX_ProgID referencing the master list
         if(is.null(keyword)){
           statement<-paste("SELECT * FROM ProgInfo WHERE RX_ProgID IN",create_IDstring(RXProgID),";",sep='')
           ProgInfo<-dbGetQuery(con,statement)
         }

        #If we gave a key word, pull all the programs then filter them below by keyword
         if(!is.null(keyword)){
            statement<-paste("SELECT * FROM ProgInfo;",sep='')
            ProgInfo<-dbGetQuery(con,statement)
         }
      }

      if(!is.null(OrgProgID)){
           #Get all OrgProgIDs specified
           statement<-paste("SELECT * FROM ProgInfo WHERE ProgID IN",create_IDstring(OrgProgID),";",sep='')
           ProgInfo<-dbGetQuery(con,statement)
      }

       statement<-paste("SELECT * FROM BudgetInfo;",sep='')
       BudgetInfo<-dbGetQuery(con,statement)

       statement<-paste("SELECT * FROM CostModelInfo;",sep='')
       CostModelInfo<-dbGetQuery(con,statement)

       CostModelID<-CostModelInfo[CostModelInfo$CostModelName=="PBB","CostModelID"]

       BudgetInfo<-BudgetInfo[BudgetInfo$CostModelID==CostModelID,]


       if(!is.null(keyword)){

         keyword<-tolower(keyword)
         keys_progname<-grep(keyword,tolower(ProgInfo$ProgName))
         keys_progdesc<-grep(keyword,tolower(ProgInfo$ProgDescription))
         progids<-unique(c(ProgInfo[keys_progname,"ProgID"],ProgInfo[keys_progdesc,"ProgID"]))
         ProgInfo<-ProgInfo[which(is.element(ProgInfo$ProgID,progids)),]
       }

       #Calculate Program Cost
       if (nrow(ProgInfo)>0){
         
         for(j in 1:nrow(ProgInfo)){
           #print(j)
           ProgID<-ProgInfo[j,'ProgID']
           rxprogid<-ProgInfo[j,'RX_ProgID']

           statement<-paste("SELECT * FROM Alloc WHERE ProgID=",ProgID," AND CostModelID=",CostModelID,";",sep='')
           Alloc<-dbGetQuery(con,statement)


        if(nrow(Alloc)>0){
             ItemIDs<-unique(Alloc$ItemID)
             statement<-paste("SELECT * FROM ItemInfo WHERE ItemID IN",create_IDstring(ItemIDs)," AND CostModelID=",CostModelID,";",sep='')
             ItemInfo<-dbGetQuery(con,statement)

             AcctIDs<-unique(ItemInfo$AcctID)
             statement<-paste("SELECT * FROM AcctInfo WHERE AcctID IN ",create_IDstring(AcctIDs),";",sep='')
             AcctInfo<-dbGetQuery(con,statement)
          
          if(nrow(AcctInfo)!=0){
               ItemInfo<-merge(ItemInfo,AcctInfo[c('AcctType','ObjType','AcctID')],by='AcctID')
               ItemInfo<-merge(ItemInfo,Alloc[c('ItemID','BudgetID','ProgID','PercentAppliedToProg')],by=c('ItemID','BudgetID'))
               ItemInfo[,'ProgCost']<-ItemInfo$TotalCost*ItemInfo$PercentAppliedToProg
               ItemInfo[,'FTE']<-ItemInfo$NumberOfItems*ItemInfo$PercentAppliedToProg
  
  
             #Now loop over budgets and build the data frame
             for (k in 1:nrow(BudgetInfo)){
               BudgetID<-BudgetInfo[k,'BudgetID']
               BudgetItemInfo<-ItemInfo[ItemInfo$BudgetID==BudgetID,]
               TotalCost<-sum(BudgetItemInfo[BudgetItemInfo$AcctType=='Expense','ProgCost'],na.rm = T)
  
               Personnel<-sum(BudgetItemInfo[BudgetItemInfo$AcctType=='Expense' & BudgetItemInfo$ObjType=='Personnel','ProgCost'],na.rm = T)
               FTE<-sum(BudgetItemInfo[BudgetItemInfo$AcctType=='Expense' & BudgetItemInfo$ObjType=='Personnel','FTE'],na.rm = T)
  
               NonPersonnel<-sum(BudgetItemInfo[BudgetItemInfo$AcctType=='Expense' & BudgetItemInfo$ObjType=='NonPersonnel','ProgCost'],na.rm = T)
               Revenue<-sum(BudgetItemInfo[BudgetItemInfo$AcctType=='Revenue','ProgCost'],na.rm = T)
  
               BudgetOrgInfo<-OrgInfo[OrgInfo$DatabaseName==DatabaseNames[i],]
  
               row<-data.frame(RX_ProgID=rxprogid,
                               ProgID=ProgInfo[j,'ProgID'],
                               RX_ProgName=RX_ProgInfo[RX_ProgInfo$RX_ProgID==rxprogid,"ProgName"][1],
                               RX_ProgDescription=RX_ProgInfo[RX_ProgInfo$RX_ProgID==rxprogid,"ProgDescription"][1],
                               TotalCost=TotalCost,
                               FTE=FTE,
                               ProgName=ProgInfo[j,'ProgName'],
                               ProgDescription=ProgInfo[j,'ProgDescription'],
                               Personnel=Personnel,
                               NonPersonnel=NonPersonnel,
                               Revenue=Revenue,
                               BudgetName=BudgetInfo[k,'BudgetName'],
                               BudgetYear=as.numeric(BudgetInfo[k,'Year']),
                               Org=BudgetOrgInfo$OrgName,
                               Pop=BudgetOrgInfo$Population,
                               DatabaseName=DatabaseNames[i],
                               Lat=BudgetOrgInfo$Latitude,
                               Long=BudgetOrgInfo$Longitude,stringsAsFactors = F)
  
               data<-rbind(data,row)
               
                    
              } #end loop over k budgets
             }}else{
               #INcldue programs we only have inventory on
              
               if(excludeZeroCost==F){
                 BudgetOrgInfo<-OrgInfo[OrgInfo$DatabaseName==DatabaseNames[i],]
                 row<-data.frame(RX_ProgID=rxprogid,
                                 ProgID=ProgInfo[j,'ProgID'],
                                 RX_ProgName=RX_ProgInfo[RX_ProgInfo$RX_ProgID==rxprogid,"ProgName"][1],
                                 RX_ProgDescription=RX_ProgInfo[RX_ProgInfo$RX_ProgID==rxprogid,"ProgDescription"][1],
                                 TotalCost=0,
                                 FTE=0,
                                 ProgName=ProgInfo[j,'ProgName'],
                                 ProgDescription=ProgInfo[j,'ProgDescription'],
                                 Personnel=0,
                                 NonPersonnel=0,
                                 Revenue=0,
                                 BudgetName=BudgetInfo[1,'BudgetName'],
                                 BudgetYear=as.numeric(BudgetInfo[1,'Year']),
                                 Org=BudgetOrgInfo$OrgName,
                                 Pop=BudgetOrgInfo$Population,
                                 DatabaseName=DatabaseNames[i],
                                 Lat=BudgetOrgInfo$Latitude,
                                 Long=BudgetOrgInfo$Longitude,stringsAsFactors = F)
                 
                 data<-rbind(data,row)
               }
            
            }# end else if had allocations
          }}# end loop over programs
        

       dbDisconnect(con)


    } #End loop over database names

    if(excludeZeroCost==T){
          data<-data[data$TotalCost>0,]
    }
    if(!is.null(data))( data<-data[order(data$Org,-data$BudgetYear,-data$TotalCost,data$ProgName),])

    return(data)
}
