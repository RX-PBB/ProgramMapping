#CRAN libraries - aka peer reviewed libraries of functions.
library(RMySQL)
library(reshape2)
library(devtools)

#Our custom Libraries:
install_github('RX-PBB/PBBMikesGeneral',force=T)
library(PBBMikesGeneral)
install_github('RX-PBB/ProgramMapping')
library(ProgramMapping)





#**********************************************************************
#
#    summarize_RXProgIDs() - Summarize program mapping.
#
#    summarize_RXProgIDs_byOrg() - Summarize cost data of mapped programs
#
#*******************************************************************
# RX_ProgInfo: Summary by Program - how often each program is used
# Org_Program_Data: Summary by Org - how many mapped programs per org.
# Below is some code you can run that will summarize the program mapping effort

#If you don't specify any databases, it will pull all non test orgs
DatabaseNames<-NULL

#Or select just a subset to summarrize
DatabaseNames<-c("RX_EnglewoodCO","RX_LittletonCO", "RX_MoffatCountyCO","RX_WheatRidgeCO","RX_ClearCreekCountyCO")
DatabaseNames<-c("RX_EnglewoodCO","RX_LittletonCO", "RX_MoffatCountyCO","RX_WheatRidgeCO","RX_ClearCreekCountyCO","")


#Output the summary files
data<-summarize_RXProgIDs(DatabaseNames)
write.csv(data$RX_ProgInfo,'RX_Proginfo.csv')
write.csv(data$Org_Program_Data,'Org_Program_Data.csv')

#Top 10 used programs
head(data$RX_ProgInfo[order(-data$RX_ProgInfo$ProgCounts),],10)

#Top 10 Orgs for # of Programs Mapped
head(data$Org_Program_Data[order(-data$Org_Program_Data$Programs_Mapped),],20)

#Summarize all the mapped prgrams from longmont
data<-RX_PrgID_data<-summarize_RXProgID_Data(RXProgID=209,DatabaseNames="RX_BeaufortSC_1")

#Summarize all cost data of RX_ProgID 209 for all orgs
data<-RX_PrgID_data<-summarize_RXProgID_Data(RXProgID=209,DatabaseNames=NULL)

data<-RX_PrgID_data<-summarize_RXProgID_Data(RXProgID=c(67,208,209),DatabaseNames=NULL)

#Summarize all programs across all orgs
data<-RX_PrgID_data<-summarize_RXProgID_Data(RXProgID=NULL,DatabaseNames=NULL)
write.csv(data,'data.csv',row.names = F)

#Loop over supplied keywords associated with the master programs and generate a summary

keyfile<-read.csv('keywords.csv',header=T,colClasses = 'character')

keyfile<-keyfile[1:26,]

temp<-NULL
for ( i in 1: nrow(keyfile)){
print(paste0(i,"  ",nrow(temp)))
    key1<-keyfile[i,'key1']
    key2<-keyfile[i,'key2']
    key3<-keyfile[i,'key3']

    x1<-NULL
    x2<-NULL
    x3<-NULL

    x1<-keyword_search(key1)
    x2<-keyword_search(key2)
    x3<-keyword_search(key3)

    temp<-rbind(temp,x1,x2,x3)
}



write.csv(temp,'keyword_search_results.csv')
keyword_search<-function(key){

  temp<-NULL

  if(!is.na(key) & key!=""){

    #search this keyword or phrase
    temp<-globalsearch(RXProgID = NULL,DatabaseNames = NULL,keyword=key)
    if(is.null(temp))(return(NULL))
    #get just one progid for each
    temp[,'dupcheck']<-paste0(temp$DatabaseName,temp$ProgID)
    temp<-temp[!duplicated(temp$dupcheck),]
    temp<-temp[,!(colnames(temp) %in% c('dupcheck'))]
    colnames(temp)[1]<-'Curr_RX_ProgID'

    #organize columns included in summary
    temp[,'Key_RX_ProgID']<-keyfile[i,'RX_ProgID']
    temp[,'RX_ProgDescription']<-keyfile[i,'ProgDescription']
    temp[,'RX_ProgName']<-keyfile[i,'ProgName']
    temp[,'key']<-key

    temp<-temp[c('key','Key_RX_ProgID','Curr_RX_ProgID','RX_ProgName','RX_ProgDescription','DatabaseName','Org','ProgID','ProgName','ProgDescription','Lat','Long','Pop')]

  }
  return(temp)
}
#**********************************************************************
#
#    get_RXProgID_Info() - echo back the master list
#
#**********************************************************************
# Use this function to echo back your changes to the RX_ProgInfo table
# Can specify an RX_ProgID or set to NULL to pull all

# Get all programs store into dataframe titled RX_ProgInfo_All
RX_ProgInfo_All<-get_RXProgID_Info(RX_ProgID=NULL)
tail(RX_ProgInfo_All)
write.csv(RX_ProgInfo_All,"RX_ProgInfo.csv",row.names = F)
# Get single programs store into dataframe titled RX_ProgInfo_Single
RX_ProgInfo_Single<-get_RXProgID_Info(RX_ProgID=1)

# Get subset of programs store into dataframe titled RX_ProgInfo_Subset
RX_ProgInfo_Subset<-get_RXProgID_Info(RX_ProgID=c(1,2,3))




#**********************************************************************
#
#    edit_RXProgID()
#
#**********************************************************************
# Can use this function and example below to edit a program from our master list

#*********************
# EXAMPLE
#*********************

#Update ProgID = 2
#Change ProgName to "Airport Access TEST"
edit_RXProgID(RX_ProgID=2,ProgName="Airport Access TEST")

#Check it!
RX_ProgInfo_Single<-get_RXProgID_Info(RX_ProgID=2)

#Change it Back!
edit_RXProgID(RX_ProgID=2,ProgName="Airport Access")

#Check it!
RX_ProgInfo_Single<-get_RXProgID_Info(RX_ProgID=2)
df<-get_RXProgID_Info(RX_ProgID=2)

#Can use the following to make changes.
#MUST specify a ProgID
#May set other fields to NULL if not updating

RX_ProgID<-2
User_Group<- NULL
Program_Name<-'Airport Access'
ServiceType<-NULL
Desc<-NULL

edit_RXProgID(RX_ProgID=RX_ProgID,ProgName=Program_Name,ItemMeta1=User_Group,ServiceType=ServiceType,ProgDescription = Desc)


#**********************************************************************
#
#    add_RXProgID()
#
#**********************************************************************
# Can use this function and example below to add a new program to our master list

#Example
User_Group<-'Code Enforcement'
Program_Name<-'Code Development'
ServiceType<-'Community'
Desc<-'Provides technical analysis of changes various international building codes and recommend amendments for adoption and implementation. (If we decide to make this not Building Dept specific, we can just remove the "international building codes" and say municipal codes?'

add_RXProgID(ItemMeta1 = User_Group,
             ServiceType=ServiceType,
             ProgName=Program_Name,
             ProgDescription=Desc)



User_Group<-'Code Enforcement'
Program_Name<-'Code Adoption'
ServiceType<-'Community'
Desc<-'Includes public hearings regarding analysis of the impact of adopting code (or code changes). Vote to adopt code or code changes based on analysis from staff and input from public hearings.'

add_RXProgID(ItemMeta1 = User_Group,
             ServiceType=ServiceType,
             ProgName=Program_Name,
             ProgDescription=Desc)



#See your new programs added
RX_ProgInfo_All<-get_RXProgID_Info(RX_ProgID=NULL)
#tail pulls last 6 rows of the table
tail(RX_ProgInfo_All)



