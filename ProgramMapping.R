#CRAN libraries - aka peer reviewed libraries of functions.
library(RMySQL)
library(reshape2)
library(devtools)

#Our custom Libraries:
install_github('RX-PBB/PBBMikesGeneral',force=T)
library(PBBMikesGeneral)
install_github('RX-PBB/ProgramMapping',force=T)
library(ProgramMapping)





#**********************************************************************
#
#    summarize_RXProgIDs() - Summarize program mapping.
#
#*******************************************************************
# RX_ProgInfo: Summary by Program - how often each program is used
# Org_Program_Data: Summary by Org - how many mapped programs per org.
# Below is some code you can run that will summarize the program mapping effort

#If you don't specify any databases, it will pull all non test orgs
DatabaseNames<-NULL

#Or select just a subset to summarrize
DatabaseNames<-c("RX_EnglewoodCO","RX_LittletonCO", "RX_MoffatCountyCO","RX_WheatRidgeCO")

#Output the summary files
data<-summarize_RXProgIDs(DatabaseNames)
write.csv(data$RX_ProgInfo,'RX_Proginfo.csv')
write.csv(data$Org_Program_Data,'Org_Program_Data.csv')




#**********************************************************************
#
#    get_RXProgID_Info() - echo back the master list
#
#**********************************************************************
# Use this function to echo back your changes to the RX_ProgInfo table
# Can specify an RX_ProgID or set to NULL to pull all

# Get all programs store into dataframe titled RX_ProgInfo_All
RX_ProgInfo_All<-get_RXProgID_Info(RX_ProgID=NULL)

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
desc<-"Provides for the background checks  fingerprinting  and other related activities for tenant and employee badging and  airport  access"
edit_RXProgID(RX_ProgID=2,ProgName="Airport Access",ItemMeta1="Airport",ServiceType="Community",ProgDescription = desc)

#Check it!
RX_ProgInfo_Single<-get_RXProgID_Info(RX_ProgID=2)


#Can use the following to make changes.
#MUST specify a ProgID
#May set other fields to NULL if not updating

RX_ProgID<-'Please Provide'
User_Group<-'Please Provide'
Program_Name<-'Please Provide'
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

User_Group<-''
Program_Name<-'Please Provide'
ServiceType<-NULL
Desc<-NULL





