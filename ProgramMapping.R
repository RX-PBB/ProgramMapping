library(RMySQL)
library(reshape2)
library(devtools)
install_github('RX-PBB/PBBMikesGeneral',force=T)
library(PBBMikesGeneral)
install_github('RX-PBB/ProgramMapping',force=T)
library(ProgramMapping)


#**********************************************************************
# summarize_RXProgIDs() - This function returns a list of 2 data frames.
#*******************************************************************
# One is a summary by Program - how often each program is used
# The second a sumary by Org - how many mapped programs per org.
# Below is some code you can run that will summarize the program mapping effort

#If you don't specify any databases, it will pull all non test orgs
DatabaseNames<-NULL

#Or select just a subset to summarrize
DatabaseNames<-c("RX_EnglewoodCO","RX_LittletonCO", "RX_MoffatCountyCO","RX_WheatRidgeCO")


data<-summarize_RXProgIDs(DatabaseNames)

write.csv(data$RX_ProgInfo,'RX_Proginfo.csv')
write.csv(data$Org_Program_Data,'Org_Program_Data.csv')


data$Org_Program_Data


#**********************************************************************
# edit_RXProgID()
#**********************************************************************
# Can use this function and example below to add a new program to our master list



#**********************************************************************
# edit_RXProgID()
#**********************************************************************
# Use this function to echo back your changes to the RX_ProgInfo table
# Can specify an RX_ProgID or set to NULL to pull all

# Get all programs store into dataframe titled RX_ProgInfo_All
RX_ProgInfo_All<-getRXProgID_Info(RX_ProgID=NULL)

# Get single programs store into dataframe titled RX_ProgInfo_Single
RX_ProgInfo_All<-getRXProgID_Info(RX_ProgID=1)

# Get subset of programs store into dataframe titled RX_ProgInfo_Subset
RX_ProgInfo_All<-getRXProgID_Info(RX_ProgID=c(1,2,3))




