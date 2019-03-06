#' Create a Parson's Problem Exercise
#'
#'
#' @import htmlwidgets
#'
#' @export
#' @examples
#' dc_parsons("def is_true(boolean_value):\n  if boolean_value:\n     return True\n  return False\n
#'  return true #distractor\n"
#' )
dc_parsons <- function(code, campus = FALSE, width = "100%", height = "auto", elementId = NULL) {

  # forward options using x
  x = list(
    code = code,
    campus = campus
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'dc_parsons',
    x,
    width = width,
    height = height,
    package = 'conceptx',
    elementId = elementId,
    dependencies = if (campus){
      htmltools::htmlDependency(
        name = 'datacamp',
        version = '0.1',
        src  = 'htmlwidgets/lib/datacamp',
        script = 'handlers.js'
      )
    } else {
      NULL
    }
  )
}

#' @import htmltools
#' @export
dc_parsons_html <- function (id, style, class, ...){
  tagList(
    tags$div(id = id, style = style, class = class,
      tags$div(id="sortableTrash", class="sortable-code"),
      tags$div(id="sortable", class="sortable-code")
    ),
    tags$div(style = "clear:both;"),
    tags$p(
      tags$a(href = '#',  id="newInstanceLink", "New instance"),
      tags$a(href = '#', id = "feedbackLink", "Get feedback")
    )
  )
}


#' Shiny bindings for dc_parsons
#'
#' Output and render functions for using dc_parsons within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a dc_parsons
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name dc_parsons-shiny
#'
#' @export
dc_parsonsOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'dc_parsons', width, height, package = 'conceptx')
}

#' @rdname dc_parsons-shiny
#' @export
renderDc_parsons <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, dc_parsonsOutput, env, quoted = TRUE)
}
