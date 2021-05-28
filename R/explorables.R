#' Create explorable
#'
#' @param path_dir Path to the directory containing the explorable. The Rmd is
#' expected to be named index.Rmd.
#' @importFrom usethis ui_info ui_code_block ui_todo ui_done
#' @export
create_explorable <- function(path_dir, browse = FALSE){
  withr::with_dir(path_dir, {
    if (file.exists('index.Rmd')){
      usethis::ui_info("Rendering Rmd to html...")
      output_type <- extract_output_type('index.Rmd')
      output_options <- if (!is.na(output_type)){
        list(css = system.file(
          'css',
          sprintf('datacamp-%s.css', output_type),
          package = 'rexplorables'
        ))
      } else {
        NULL
      }
      rmarkdown::render(
        'index.Rmd', encoding = 'UTF-8', quiet = TRUE,
        output_options = output_options
      )

      usethis::ui_info("Updating html to custom datacamp theme...")
      index <- paste(readLines("index.html", warn = FALSE), collapse = "\n")
      index %>%
        gsub(
          "index_files/bootstrap-3.3.5/css/cosmo.min.css",
          "https://explorables.datacamp.com/latest/themes/bootstrap.min.css",
          .,
          fixed = TRUE
        ) %>%
        gsub(
          "index_files/plotly-main-1.46.1/plotly-latest.min.js",
          "https://cdnjs.cloudflare.com/ajax/libs/plotly.js/1.46.1/plotly-basic.min.js",
          .,
          fixed = TRUE
        ) %>%
        cat(file = "index.html")
    }
    if (browse){
      browseURL('index.html')
    }
  })
  usethis::ui_info('Zipping explorable...')
  zip_explorables(path_dir, extras = '-qq -x "*.Rmd"')
  usethis::ui_done(
    glue::glue('Your explorable has been saved as {paste0(basename(path_dir), ".zip")}')
  )
  usethis::ui_todo("Upload it as an asset in the teach editor")
  usethis::ui_todo("Add this snippet to the pre-exercise-code")
  usethis::ui_code_block(c(
    "# Replace ___ with url to zip in teach",
    "rexplorables::copy_explorable(url)",
    "displayPage('{ basename(path_dir) }/')"
  ))
}

extract_output_type <- function(f){
  fm <- rmarkdown::yaml_front_matter(f)
  if ('output' %in% names(fm)){
    strsplit(names(fm$output), "::", fixed = TRUE)[[1]][1]
  } else {
    NA
  }
}

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
