#' When disconnecting, there is an option `force` to either warn if there are
#' open results for the connection and immediately finalize all affected objects
#' (default) or to simply inform about open results and mark the connection for
#' finalization (which is triggered when the last open result is closed).
#' @rdname dbConnect
#' @inheritParams DBI::dbDisconnect
#' @param force Close open results when disconnecting
#' @usage NULL
dbDisconnect_AdbiConnection <- function(conn,
    force = getOption("adbi.force_close_results", FALSE), ...) {

  n_res <- length(meta(conn, "results"))

  if (n_res && isTRUE(force)) {

    warning("There are ", n_res, " open result(s) in use. Force closing ",
      "can be disabled by setting `options(adbi.force_close_results = FALSE)`.")

    clear_results(conn)

  } else if (n_res) {

    message("There are ", n_res, " result(s) in use. The connection will be ",
      "released when they are closed")

    meta(conn, "disconnect") <- TRUE

    return(invisible(FALSE))
  }

  if (adbc_connection_is_valid(conn@connection)) {

    adbc_release(conn@connection, "connection")

  } else {

    warning("Connection already closed.", call. = FALSE)
  }

  if (adbc_database_is_valid(conn@database)) {

    adbc_release(conn@database, "database")

  } else {

    warning("Database already released.", call. = FALSE)
  }

  invisible(TRUE)
}

#' @rdname dbConnect
#' @export
setMethod("dbDisconnect", "AdbiConnection", dbDisconnect_AdbiConnection)
