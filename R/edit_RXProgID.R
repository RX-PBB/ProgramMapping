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



edit_RXProgID<-function(RX_ProgID,	ItemMeta1=NULL,	ServiceType=NULL,	ProgName=NULL,	ProgDescription=NULL){


    db_host<-'ec2-52-11-250-69.us-west-2.compute.amazonaws.com'
    db_name<-'RX_Admin'

    con <- dbConnect(MySQL(),
                       user="mtseman",
                       password="cree1234",
                       host=db_host,
                       dbname=db_name)

    for (dataField in c('ItemMeta','ServiceType','ProgName','ProgDescription')){

        if (!is.null(dataField)){

          dataField<-trim(dataField)
          dataField<-gsub("'","''",dataField)

          statement<-paste0("UPDATE RX_ProgInfo SET ",dataField," = '",dataField,"' WHERE RX_ProgID = ",RX_ProgID,";")
          rs<-dbSendQuery(con,statement)
          dbClearResult(rs)

        }

       print(dataField)
    }




    dbDisconnect(con)

}
