is_datacamp <- function() {
  Sys.getenv("DATACAMP") != "" && Sys.getenv("DATACAMP") == "1"
}

#' Get path to www directory
#'
#' @param local_www_dir local www directory
get_www_dir <- function(local_www_dir = tempdir()){
  if (is_datacamp()) {
    www_dir <- Sys.getenv("SERVER_PUBLIC_DIRECTORY", NA)
    shiny_folder <- "/srv/shiny-server"
    # TODO: next block makes RBackend backward compatible for r-shiny-prod <= v1.1.1 and r-file-server-prod <= v1.1.2
    if (is.na(www_dir)) {
      if (dir.exists(shiny_folder)) {
        www_dir <- shiny_folder
      } else {
        www_dir <- "/var/www"
      }
    }
  } else {
    www_dir <- local_www_dir
    dir.create(www_dir, recursive = TRUE, showWarnings = FALSE)
  }
  return(www_dir)
}

#' Write environment variable
#'
#' This lets environment authors set environment variables in requirements.R
#' that get copied over to the course image, and available to all exercises
#' @param ... environment variables to copy
#' @param file path to environment file to copy the variables to
#' @export
#' @examples
#' \dontrun{
#'   write_envvar(DC_SHINY = "1")
#' }
write_envvar <- function(..., file = '/etc/R/Renviron'){
  dots <- list(...)
  vars <- paste(paste0(names(dots), "=", dots), collapse = "\n")
  cat(vars, file = file, append = TRUE)
}

#' Write function to Rprofile.site
#'
#' This will make the function globally available to all exercises.
#' @param fun function to write to Rprofile.site
#' @param file the file to write the function to
#' @export
#' @examples
#' \dontrun{
#'  tf <- tempfile(fileext = '.R')
#'  add <- function(x, y){
#'    x + y
#'  }
#'  write_fun(add, file = tf)
#'  cat(paste(readLines(tf, warn = FALSE), collapse = '\n'))
#' }
write_fun <- function(fun, file = '/etc/R/Rprofile.site'){
  y <- deparse(substitute(fun));
  fun_chr <- utils::capture.output(match.fun(y))
  fun_chr[1] <- sprintf("\n%s <- %s", y, fun_chr[1])
  cat(paste(c(fun_chr, "\n"), collapse = "\n"), file = file, append = TRUE)
}

check_shiny_installed <- function(){
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package \"shiny\" needed for this function to work. Please install it.",
      call. = FALSE)
  }
}
