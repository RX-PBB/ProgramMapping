#' edit_RXProgID
#'
#' Update an RX master program by ID
#' @param RX_ProgID The ID of the program to update
#' @param ItemMeta1 User group aka where to file this program under
#' @param ServiceType Typically Community or Governance.
#' @param ProgName The program name
#' @param ProgDescription The Program description
#' @export
#' @examples
#' edit_RXProgID(RX_ProgID=1,ProgName='Updated ProgName')
#' edit_RXProgID(RX_ProgID=1,ProgName='Updated ProgName',ItemMeta1='New user group')
#' Need to specify the RX_ProgID and then reference a column for updating. You may specify any combinations of ItemMeta1, ServiceType, ProgName, or ProgDEscription for updating



edit_RXProgID<-function(RX_ProgID,	ItemMeta1=NULL,	ServiceType=NULL,	ProgName=NULL,	ProgDescription=NULL,db.settings){

    if(!is.null(RX_ProgID)){
       

        con <- dbConnect(MySQL(),
                          user=db.settings$user,
                           password=db.settings$pw,
                           host=db.settings$host,
                           dbname=db.settings$db_admin)



            if (!is.null(ItemMeta1)){

              ItemMeta1<-trim(ItemMeta1)
              ItemMeta1<-gsub("'","''",ItemMeta1)

              statement<-paste0("UPDATE RX_ProgInfo SET ItemMeta1 = '",ItemMeta1,"' WHERE RX_ProgID = ",RX_ProgID,";")
              rs<-dbSendQuery(con,statement)
              dbClearResult(rs)

            }

            if (!is.null(ServiceType)){

              ServiceType<-trim(ServiceType)
              ServiceType<-gsub("'","''",ServiceType)

              statement<-paste0("UPDATE RX_ProgInfo SET ServiceType = '",ServiceType,"' WHERE RX_ProgID = ",RX_ProgID,";")
              rs<-dbSendQuery(con,statement)
              dbClearResult(rs)

            }

            if (!is.null(ProgName)){

              ProgName<-trim(ProgName)
              ProgName<-gsub("'","''",ProgName)

              statement<-paste0("UPDATE RX_ProgInfo SET ProgName = '",ProgName,"' WHERE RX_ProgID = ",RX_ProgID,";")
              rs<-dbSendQuery(con,statement)
              dbClearResult(rs)

            }

            if (!is.null(ProgDescription)){

              ProgDescription<-trim(ProgDescription)
              ProgDescription<-gsub("'","''",ProgDescription)

              statement<-paste0("UPDATE RX_ProgInfo SET ProgDescription = '",ProgDescription,"' WHERE RX_ProgID = ",RX_ProgID,";")
              rs<-dbSendQuery(con,statement)
              dbClearResult(rs)

            }

          dbDisconnect(con)

    }

}
