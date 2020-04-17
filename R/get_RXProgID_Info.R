#' get_RXProgID_Info
#'
#' Echo back RX master list
#' @param RX_ProgID The ID of the program info to get. Set to NULL to pull all programs. Provide a vector of indexes to pull a subset.
#' @export
#' @examples
#' edit_RXProgID(RX_ProgID=1,ProgName='Updated ProgName')
#' edit_RXProgID(RX_ProgID=1,ProgName='Updated ProgName',ItemMeta1='New user group')
#' Need to specify the RX_ProgID and then reference a column for updating. You may specify any combinations of ItemMeta1, ServiceType, ProgName, or ProgDEscription for updating



get_RXProgID_Info<-function(RX_ProgID,db.settings){



    con <- dbConnect(MySQL(),
                      user=db.settings$user,
                           password=db.settings$pw,
                           host=db.settings$host,
                           dbname=db.settings$db_admin)


    if(!is.null(RX_ProgID)){

      statement<-paste("SELECT * FROM RX_ProgInfo WHERE RX_ProgID IN ",create_IDstring(RX_ProgID),";",sep='')
      df<-dbGetQuery(con,statement)
    }

    if(is.null(RX_ProgID)){

      statement<-paste("SELECT * FROM RX_ProgInfo;",sep='')
      df<-dbGetQuery(con,statement)
    }


    dbDisconnect(con)


    return(df)

}
