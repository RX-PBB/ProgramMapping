#Load these libraries - Libraries are sets of functions we can call and use.

#CRAN libraries - aka peer reviewed libraries of functions. Well trusted and documented
library(RMySQL)
library(reshape2)
library(devtools)

#Our custom Libraries: homegrown
#install_github('RX-PBB/PBBMikesGeneral',force=T)
library(PBBMikesGeneral)
#install_github('RX-PBB/ProgramMapping')
library(ProgramMapping)


db_host<-'ec2-52-11-250-69.us-west-2.compute.amazonaws.com'
db_name<-'RX_Admin'

#***********************************************************
# Get all non test database names from admin database
#**********************************************************
con <- dbConnect(MySQL(),
                 user="mtseman",
                 password="cree1234",
                 host=db_host,
                 dbname=db_name)

    statement<-paste("SELECT * FROM OrgInfo;",sep='')
    OrgInfo<-dbGetQuery(con,statement)
    
    DatabaseNames<-sort(unique(OrgInfo[OrgInfo$IsTestOrg==0,'DatabaseName']))

dbDisconnect(con)


#****************************************
# Query all and write a file
#****************************************

masterlist<-NULL
for (i in 1:length(DatabaseNames)){
  #print(DatabaseNames[i])
  #Get ProgInfo for
  con <- dbConnect(MySQL(),
                   user="mtseman",
                   password="cree1234",
                   host=db_host,
                   dbname=DatabaseNames[i])
  
  statement<-paste("SELECT * FROM ProgInfo ;",sep='')
  ProgInfo<-dbGetQuery(con,statement)
  
  dbDisconnect(con)
  
  infonames<-colnames(ProgInfo)
  if(length(infonames)==26){
      if(nrow(ProgInfo)>0){
          print(DatabaseNames[i])
          ProgInfo[,'RX_Database']<-DatabaseNames[i]
          ProgInfo[,'OrgName']<-OrgInfo[OrgInfo$DatabaseName==DatabaseNames[i],'OrgName']
          
          
          ProgInfo<-ProgInfo[c('OrgName','RX_Database',infonames)]
          
          masterlist<-rbind(masterlist,ProgInfo)
      }
  }
}
  
write.csv(masterlist,"ProgInfo_ALL.csv")


#******************************************************************************
# Create the same list but instead do it for just a specific set of clients
#******************************************************************************

DatabaseNames<-read.csv("db_subset.csv",header=T)
DatabaseNames<-DatabaseNames$X1DatabaseName
DatabaseNames<-as.character(DatabaseNames)

masterlist<-NULL
for (i in 1:length(DatabaseNames)){
  #print(DatabaseNames[i])
  #Get ProgInfo for
  con <- dbConnect(MySQL(),
                   user="mtseman",
                   password="cree1234",
                   host=db_host,
                   dbname=DatabaseNames[i])
  
  statement<-paste("SELECT * FROM ProgInfo ;",sep='')
  ProgInfo<-dbGetQuery(con,statement)
  
  dbDisconnect(con)
  
  infonames<-colnames(ProgInfo)
  if(length(infonames)==26){
    if(nrow(ProgInfo)>0){
      print(DatabaseNames[i])
      ProgInfo[,'RX_Database']<-DatabaseNames[i]
      ProgInfo[,'OrgName']<-OrgInfo[OrgInfo$DatabaseName==DatabaseNames[i],'OrgName']
      
      
      ProgInfo<-ProgInfo[c('OrgName','RX_Database',infonames)]
      
      masterlist<-rbind(masterlist,ProgInfo)
    }
  }
}

write.csv(masterlist,"ProgInfo_Sunset.csv")
