#' add_RXProgID
#'
#' Add a program to the RX_Master lsit
#' @param ItemMeta1 User group aka where to file this program under
#' @param ServiceType Typically Community or Governance.
#' @param ProgName The program name
#' @param ProgDescription The Program description
#' @export
#' @examples
#' edit_RXProgID(RX_ProgID=1,ProgName='Updated ProgName')
#' edit_RXProgID(RX_ProgID=1,ProgName='Updated ProgName',ItemMeta1='New user group')
#' Need to specify the RX_ProgID and then reference a column for updating. You may specify any combinations of ItemMeta1, ServiceType, ProgName, or ProgDEscription for updating



add_RXProgID<-function(ItemMeta1,	ServiceType,	ProgName,	ProgDescription){


    row<-data.frame(ItemMeta1=ItemMeta1,
                    ServiceType=ServiceType,
                    ProgName=ProgName,
                    ProgDescription=ProgDescription,stringsAsFactors=F)

    row<-db_clean(row)
    updateFields<-colnames(row)

    db_host<-'ec2-52-11-250-69.us-west-2.compute.amazonaws.com'
    db_name<-'RX_Admin'

    con <- dbConnect(MySQL(),
                           user="mtseman",
                           password="cree1234",
                           host=db_host,
                           dbname=db_name)



    doUpdateFullQueryAnyAny_MS(con, tableName='RX_ProgInfo', dfFull=row, updateFields=updateFields, batchSize=500)

    dbDisconnect(con)

}
