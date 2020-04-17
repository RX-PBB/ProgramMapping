#' summarize_RXProgIDs
#'
#' Creates two summary dataframes. One is a summary by Program - how often each program is used The second a sumary by Org - how many mapped programs per org.
#' @param DatabaseNames names of the PBB databases to summarrize, set to NULL for all databases. Will exclude test databases
#' @param db.settings Database user, host, pw
#' @export
#' @examples
#' data<-summarize_RXProgIDs(DatabaseNames)
#' write.csv(data$RX_ProgInfo,'RX_Proginfo.csv')
#' write.csv(data$Org_Program_Data,'Org_Program_Data.csv')



summarize_RXProgIDs<-function(DatabaseNames=NULL,db.settings){

    

    con <- dbConnect(MySQL(),
                      user=db.settings$user,
                           password=db.settings$pw,
                           host=db.settings$host,
                           dbname=db.settings$db_admin)

       statement<-paste("SELECT * FROM OrgInfo;",sep='')
       OrgInfo<-dbGetQuery(con,statement)

       statement<-paste("SELECT * FROM RX_ProgInfo;",sep='')
       RX_ProgInfo<-dbGetQuery(con,statement)



    dbDisconnect(con)

    if(is.null(DatabaseNames)){
    DatabaseNames<-sort(unique(OrgInfo[OrgInfo$IsTestOrg==0,'DatabaseName']))
    }



    temp<-NULL
    ProgInfo_Master<-NULL

    for (i in 1:length(DatabaseNames)){
      
      print(paste0(DatabaseNames[i],": ",OrgInfo[OrgInfo$DatabaseName==DatabaseNames[i],'OrgName']))
      
      con <- dbConnect(MySQL(),
                       user=db.settings$user,
                       password=db.settings$pw,
                       host=db.settings$host,
                       dbname=DatabaseNames[i])

       statement<-paste("SELECT * FROM ProgInfo;",sep='')
       ProgInfo<-dbGetQuery(con,statement)

       dbDisconnect(con)

       Programs_Total<-nrow(ProgInfo)
       Programs_Unique<-nrow(ProgInfo[is.na(ProgInfo$RX_ProgID),])
       Programs_Mapped<-nrow(ProgInfo[!is.na(ProgInfo$RX_ProgID),])
       Programs_Mapped_Unique<-length(unique(ProgInfo[(!is.na(ProgInfo$RX_ProgID)),'RX_ProgID']))


       row<-data.frame(OrgName=OrgInfo[OrgInfo$DatabaseName==DatabaseNames[i],'OrgName'],
                       Programs_Total=Programs_Total,
                       Programs_Unique=Programs_Unique,
                       Programs_Mapped=Programs_Mapped,
                       Programs_Mapped_Unique=Programs_Mapped_Unique)

       temp<-rbind(temp,row)
       
       if (ncol(ProgInfo)==26){
       ProgInfo_Master<-rbind(ProgInfo_Master,ProgInfo)
       }



    }

    Org_Program_Data<-temp


    ProgInfo_Master<-split(ProgInfo_Master,ProgInfo_Master$RX_ProgID)

    temp<-NULL
    for (i in 1:length(ProgInfo_Master)){

      row<-data.frame(RX_ProgID=ProgInfo_Master[[i]][1,'RX_ProgID'],
                      Counts=nrow(ProgInfo_Master[[i]][!is.na(ProgInfo_Master[[i]]$RX_ProgID),])
      )

      temp<-rbind(temp,row)

    }

    Counts_Program_Data<-temp

    RX_ProgInfo<-merge(RX_ProgInfo,Counts_Program_Data,by='RX_ProgID',all.x=T)
    RX_ProgInfo[,'ProgCounts']<-RX_ProgInfo[,'Counts']
    RX_ProgInfo<-RX_ProgInfo[-c(7)]

    data<-list()
    data$RX_ProgInfo<-RX_ProgInfo
    data$Org_Program_Data<-Org_Program_Data

    return(data)
}
