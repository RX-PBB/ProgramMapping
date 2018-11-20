library(RMySQL)
library(reshape2)



#**********************************************************************
# summarize_RXProgIDs() - This function returns a list of 2 data frames.
#*******************************************************************
# One is a summary by Program - how often each program is used
# The second a sumary by Org - how many mapped programs per org.

#If you don't specify any databases, it will pull all non test orgs
DatabaseNames<-NULL

#Or select just a subset to summarrize
DatabaseNames<-c("RX_EnglewoodCO","RX_LittletonCO", "RX_MoffatCountyCO","RX_WheatRidgeCO")



data<-summarize_RXProgIDs(DatabaseNames)

write.csv(data$RX_ProgInfo,'RX_Proginfo.csv')
write.csv(data$Org_Program_Data,'Org_Program_Data.csv')


data$Org_Program_Data

#**********************************************
#
# FUNCTION: Summarrize Master Programs
#
#**************************************************

summarize_RXProgIDs<-function(DatabaseNames=NULL){
  
    db_host<-'ec2-52-11-250-69.us-west-2.compute.amazonaws.com'
    db_name<-'RX_Admin'
    
    con <- dbConnect(MySQL(),
                       user="mtseman",
                       password="cree1234",
                       host=db_host,
                       dbname=db_name)
    
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
      
      con <- dbConnect(MySQL(),
                       user="mtseman",
                       password="cree1234",
                       host=db_host,
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
       
       ProgInfo_Master<-rbind(ProgInfo_Master,ProgInfo)
       print(paste0(DatabaseNames[i],": ",OrgInfo[OrgInfo$DatabaseName==DatabaseNames[i],'OrgName']))
       
     
      
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



