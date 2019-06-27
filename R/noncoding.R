#' Shiny module to create a non-coding exercise
#'
#' @export
#' @param input standard \code{shiny} boilerplate
#' @param output standard \code{shiny} boilerplate
#' @param session standard \code{shiny} boilerplate
#' @param feedback a reactive that returns a named list with a
#'   message and feedback
#' @examples
#' \dontrun{
#'  library(shiny)
#'  num <- sample(1:10, 1)
#'
#'  check_exercise <- function(actual, guess){
#'    if(actual == guess){
#'      list(message = "Well Done!", success = TRUE)
#'    } else {
#'      msg <- sprintf("You guessed %s. Please try again!", guess)
#'      list(message = msg, success = FALSE)
#'    }
#'  }
#'
#'  ui <- fluidPage(
#'    theme = shinythemes::shinytheme('cosmo'),
#'    titlePanel('Guess the Number'),
#'    mainPanel(
#'      sliderInput('num', 'Select number', 0, 10, 2),
#'      non_coding_ui('feedback')
#'    )
#'  )
#'
#'  server <- function(input, output, session){
#'    feedback <- reactive({
#'      check_exercise(num, input$num)
#'    })
#'    shiny::callModule(non_coding, 'feedback', feedback)
#'  }
#'  shinyApp(ui = ui, server = server)
#'}
non_coding <- function(input, output, session, feedback){
  check_shiny_installed()
  shiny::observeEvent(input$submit, {
    print(feedback())
    session$sendCustomMessage("campus", feedback())
    if (is_not_campus()){
      output$feedback <- shiny::renderUI({
        display_feedback(
          shiny::isolate(feedback())
        )
      })
    }
  })
}

#' @rdname non_coding
#' @param id id to call the module with
#' @export
non_coding_ui <- function(id){
  check_shiny_installed()
  ns <- shiny::NS(id)
  ui <- if (is_not_campus()){
    shiny::tagList(
      shiny::actionButton(ns('submit'), label = 'Submit'),
      shiny::tags$hr(),
      shiny::uiOutput(ns('feedback'))
    )
  } else {
    NULL
  }
  shiny::tagList(
    ui,
    shiny::tags$script(
      sprintf(
        "window.LOCAL = %s",
        # jsonlite::toJSON(is_not_campus(), auto_unbox = TRUE)
        if (is_not_campus()) "true" else "false"
      )
    ),
    shiny::tags$script(shiny::HTML(
      js_funs_noncoding(id = ns('submit'))
    ))
  )
}


is_not_campus <- function(){
  Sys.info()[['sysname']] == 'Darwin'
}

display_feedback <- function(p){
  if (p$success){
    shiny::div(class = 'alert alert-success', p$message)
  } else {
    shiny::div(class = 'alert alert-warning', p$message)
  }
}


js_funs_noncoding <- function(id){
  sprintf("
  setupCampusHandlers();

  function isCampus(){
    return(typeof(LOCAL) === 'undefined' || !LOCAL);
  }

  function setupCampusHandlers(){
    if (isCampus()) {
      // send message that client is ready
      postClientReady();
      if (window.Shiny){
        // set up event listener for submit button
        window.addEventListener('message', ({ data }) => {
          if (data.channelName === 'NonCodingExerciseInnerFrame') {
            if (data.action === 'SUBMIT_ANSWER'){
              console.log('Submitting Answer ...');
              // trigger a submit event that the shiny server can listen to
              Shiny.setInputValue('%s', 1, {priority: 'event'});
            }
          }
        });
      }
    }
    Shiny.addCustomMessageHandler('campus', function(message){
      postExerciseCompleted(message.message, message.success);
    });
  }

  function postClientReady(){
    const CLIENT_READY = {
      action: 'CLIENT_READY',
      channelName: 'NonCodingExerciseInnerFrame'
    };
    window.parent.postMessage(CLIENT_READY, '*');
  }


  function postExerciseCompleted(message, success) {
    const EXERCISE_COMPLETED = {
      action: 'CHECK_EXERCISE_COMPLETED',
      channelName: 'NonCodingExerciseInnerFrame',
      payload: {success: success, message: message}
    };
    console.log(JSON.stringify(EXERCISE_COMPLETED));
    if (isCampus()){
      window.parent.postMessage(EXERCISE_COMPLETED, '*');
    }
  }
  ", id)
}
