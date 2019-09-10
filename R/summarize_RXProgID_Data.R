#' summarize_RXProgID_Data
#'
#' Returns a table of Orgs that offer the RX_ProgID. Includes Cost and breakout by Org budget and year.
#' @param RXProgID names of the PBB databases to summarrize, set to NULL for all databases. Will exclude test databases
#' @param DatabaseNames names of the PBB databases to summarrize, set to NULL for all databases. Will exclude test databases
#' @export
#' @examples
#' data<-summarize_RXProgID_Data(RXProgID=1,DatabaseNames)


summarize_RXProgID_Data<-function(RXProgID,DatabaseNames=NULL){

    db_host<-'ec2-52-11-250-69.us-west-2.compute.amazonaws.com'
    db_name<-'RX_Admin'
    data<-NULL

    con <- dbConnect(MySQL(),
                       user="mtseman",
                       password="cree1234",
                       host=db_host,
                       dbname=db_name)

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
                       user="mtseman",
                       password="cree1234",
                       host=db_host,
                       dbname=DatabaseNames[i])

       statement<-paste("SELECT * FROM ProgInfo WHERE RX_ProgID IN",create_IDstring(RXProgID),";",sep='')
       ProgInfo<-dbGetQuery(con,statement)

       statement<-paste("SELECT * FROM BudgetInfo;",sep='')
       BudgetInfo<-dbGetQuery(con,statement)

       statement<-paste("SELECT * FROM CostModelInfo;",sep='')
       CostModelInfo<-dbGetQuery(con,statement)
       
       statement<-paste("SELECT * FROM ProgBudgetInfo;",sep='')
       ProgBudgetInfo<-dbGetQuery(con,statement)
      
       statement<-paste("SELECT * FROM PBBComments;",sep='') 
       PBBComments<-dbGetQuery(con,statement)

       CostModelID<-CostModelInfo[CostModelInfo$CostModelName=="PBB",]

       #Calculate Program Cost
       if (nrow(ProgInfo)>0){

         
         for(j in 1:nrow(ProgInfo)){
           #print(j)
           # if(i==11){
           #   if(j==12)(browser())
           # }
           ProgID<-ProgInfo[j,'ProgID']
           rxprogid<-ProgInfo[j,'RX_ProgID']

           statement<-paste("SELECT * FROM Alloc WHERE ProgID=",ProgID,";",sep='')
           Alloc<-dbGetQuery(con,statement)
           
          
           if(nrow(Alloc)>0){
             ItemIDs<-unique(Alloc$ItemID)
             statement<-paste("SELECT * FROM ItemInfo WHERE ItemID IN",create_IDstring(ItemIDs)," AND CostModelID=",CostModelID,";",sep='')
             ItemInfo<-dbGetQuery(con,statement)

             AcctIDs<-unique(ItemInfo$AcctID)
             statement<-paste("SELECT * FROM AcctInfo WHERE AcctID IN",create_IDstring(AcctIDs),";",sep='')
             AcctInfo<-dbGetQuery(con,statement)

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
             
             ProgBudgetNote<-ProgBudgetInfo[ProgBudgetInfo$BudgetID==BudgetID & ProgBudgetInfo$ProgID==ProgInfo[j,'ProgID'],'ProgBudgetNote']
             PBBCommentID<-ProgBudgetInfo[ProgBudgetInfo$BudgetID==BudgetID & ProgBudgetInfo$ProgID==ProgInfo[j,'ProgID'],'PBBCommentID']
             
             PBBComment<-PBBComments[PBBComments$PBBCommentID==PBBCommentID,'PBBComment']
             
             if(length(ProgBudgetNote)==0)(ProgBudgetNote<-NA)
             if(length(PBBComment)==0)(PBBComment<-NA)
             
             row<-data.frame(RX_ProgID=rxprogid,
                             ProgID=ProgInfo[j,'ProgID'],
                             RX_ProgName=RX_ProgInfo[RX_ProgInfo$RX_ProgID==rxprogid,"ProgName"],
                             RX_ProgDescription=RX_ProgInfo[RX_ProgInfo$RX_ProgID==rxprogid,"ProgDescription"],
                             TotalCost=TotalCost,
                             FTE=FTE,
                             ProgName=ProgInfo[j,'ProgName'],
                             ProgDescription=ProgInfo[j,'ProgDescription'],
                             PBBComment=PBBComment,
                             BudgetNote=ProgBudgetNote,
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
           }# end if this program had any allocations
           
         }} #End loop over Programs that matched RX_ProgID within an Org DatabaseName

       dbDisconnect(con)


    } #End loop over database names

    data<-data[data$TotalCost>0,]
    if(!is.null(data))( data<-data[order(data$Org,-data$BudgetYear,-data$TotalCost,data$ProgName),])

    return(data)
}
