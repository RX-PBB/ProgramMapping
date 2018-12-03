#' edit_RXProgID
#'
#' Updte an RX master program by ID
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

    if (!is.null(ItemMeta1)){

      statement<-paste0("UPDATE RX_ProgInfo SET ItemMeta1 = '",ItemMeta1,"' WHERE CustomerID = ",RX_ProgID,";")
      rs<-dbSendQuery(con,statement)
      dbClearResult(rs)

    }

    if (!is.null(ServiceType)){

      statement<-paste0("UPDATE RX_ProgInfo SET ServiceType = '",ServiceType,"' WHERE CustomerID = ",RX_ProgID,";")
      rs<-dbSendQuery(con,statement)
      dbClearResult(rs)

    }

    if (!is.null(ProgName)){

      statement<-paste0("UPDATE RX_ProgInfo SET ProgName = '",ProgName,"' WHERE CustomerID = ",RX_ProgID,";")
      rs<-dbSendQuery(con,statement)
      dbClearResult(rs)

    }

    if (!is.null(ProgDescription)){

      statement<-paste0("UPDATE RX_ProgInfo SET ProgDescription = '",ProgDescription,"' WHERE CustomerID = ",RX_ProgID,";")
      rs<-dbSendQuery(con,statement)
      dbClearResult(rs)

    }


    dbDisconnect(con)

}
