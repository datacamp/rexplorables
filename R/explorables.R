#' Display Explorable in the HTML Viewer
#'
#' This function can be used to display an explorable web app in a
#' @param path Path to the folder containing index.html.
#' @param subdir The parent directory for the course.
#' @param cdn A boolean indicating if asset should be served from CDN.
#' @param type A string indicating whether to use dev, staging, or prod.
#' @param version A string indicating the version of the asset.
#' @param index Name of the html file (defaults to index.html)
#' @export
display_explorable <- function(path,
                               subdir = Sys.getenv('DC_EXPLORABLES_SUBDIR', ""),
                               cdn = Sys.getenv('DC_EXPLORABLES_CDN', FALSE),
                               type = Sys.getenv('DC_EXPLORABLES_TYPE', 'dev'),
                               version = 'latest',
                               index = 'index.html'){
  subdir <- if (subdir == "") NULL else subdir

  # Absolute
  if (grepl('^http', path)){
    link <- path
    class(link) <- "html_link"
    return(link)
  }

  # Relative
  if (grepl('^explorables', path)){
    if (requireNamespace("RBackend", quietly = TRUE)){
      return(RBackend::displayPage(path))
    }
  }

  # Explorable
  type <- match.arg(type, c('dev', 'staging', 'prod'))
  link_base <- if (cdn){
    if (type == "dev"){
      "https://explorables.datacamp-staging.com/dev/latest"
    } else if (type == "staging") {
      "https://explorables.datacamp-staging.com/staging/latest"
    } else {
      "https://explorables.datacamp.com/latest"
    }
  } else {
    if (type == "dev"){
      paste0(
        "https://s3.amazonaws.com/explorables.datacamp-staging.com/live/dev/",
        version
      )
    } else if (type == "staging") {
      paste0(
        "https://s3.amazonaws.com/explorables.datacamp-staging.com/live/staging/",
        version
      )
    } else {
      paste0(
        "https://s3.amazonaws.com/explorables.new.datacamp.com/live/latest/",
        version
      )
    }
  }
  link <- paste(c(link_base, subdir, path, index), collapse = "/")
  class(link) <- "html_link"
  link
}


#' Zip a folder containing explorables
#'
#' @param path path to explorables
#' @export
#' @importFrom utils capture.output download.file unzip
zip_explorables <- function(path = 'explorables', ...){
  zipfile <- basename(path)
  files <- list.files(path, recursive = TRUE, full.names = TRUE)
  utils::zip(zipfile, files = files, ...)
}


#' Copy explorables to www directory
#'
#' @param url url to the zipfile containig explorables (explorables.zip)
#' @export
copy_explorables <- function(url){
  to <- get_www_dir()
  zip_file_dest <- file.path(to, basename(url))
  if (grepl('^http', url)){
    utils::download.file(url, dest = zip_file_dest)
  } else {
    file.copy(url, to = zip_file_dest, overwrite = TRUE)
  }
  on.exit({
    unlink(file.path(to, '__MACOSX'), recursive = TRUE)
    unlink(zip_file_dest)
  })
  utils::unzip(zip_file_dest, exdir = to)
  return(to)
}
