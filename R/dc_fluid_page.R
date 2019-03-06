#' Create a conceptual exercise with fluid layout
#'
#'
#'
#' @export
#' @examples
#' num <- sample(1:10, 1)
#' ui <- dc_fluid_page(
#'   theme = shinythemes::shinytheme('cosmo'),
#'   titlePanel('Guess the Number'),
#'   mainPanel(
#'     sliderInput('num', 'Select number', 0, 10, 2),
#'     actionButton('submit', label = 'Submit'),
#'     uiOutput('num')
#'   )
#' )
#' server <- function(input, output, session){
#'    payload <- reactive({
#'      num_selected <- input$num
#'      message <- if (num_selected == num){
#'        list(success = TRUE, message = 'Well Done!')
#'      } else {
#'        list(success = FALSE, message = 'Sorry! Try Again...')
#'      }
#'    })
#'    observeEvent(input$submit, {
#'      session$sendCustomMessage("campus", payload())
#'    })
#'  }
#'  if (interactive()){
#'    shinyApp(ui = ui, server = server)
#' }
#'
#' dc_fluid_page(
#'   titlePanel('Guess the Number'),
#'   mainPanel(
#'     tags$input("v-model" = "num",
#'       type = 'number', min = "0", max = "10", step = "1"
#'     ),
#'     tags$button(type = "submit", "Submit Answer", `@click` = "submit")
#'   ) %>%
#'   vuepkg::vue(
#'     data = list(num = 2),
#'     methods = list(
#'       submit = htmlwidgets::JS("function(){
#'          if (this.num == 6){
#'            checkExercise(true, 'Well done!')
#'          } else {
#'            checkExercise(false, 'Sorry, Try Again!')
#'          }
#'       }")
#'     )
#'   )
#' ) %>%
#' htmltools::browsable()
dc_fluid_page <- function(..., title = NULL, theme = NULL,
    local = Sys.info()[['sysname']] == "Darwin" ){
  shiny::fluidPage(
    ..., dc_conceptx_js(local = local), title = title, theme = theme
  )
}

dc_conceptx_js <- function(local = Sys.info()[['sysname']] == "Darwin"){
  js_file <- system.file(
    'htmlwidgets', 'lib', 'datacamp', 'handlers.js', package = 'conceptx'
  )
  tagList(
    tags$script(
      sprintf("window.LOCAL = %s",
        jsonlite::toJSON(local, auto_unbox = TRUE
      ))
    ),
    shiny::includeScript(js_file)
  )
}
