library(shiny)
library(ggplot2)
library(dplyr)
library(rexplorables)

generate_data = function(difficulty, numPoints){
  value = rnorm(1,0,10)
  valueB = rnorm(1,4,1)
  outlier = as.numeric( sample(2:6, 1)) #create a random number
  if (difficulty ==2){ # with outlier
    choice = sample(2,1)
    if (choice ==2){
      X1 = rnorm(numPoints,value,valueB)
      Y1 = rnorm(numPoints,rnorm(1)*X1,rgamma(1,1)*valueB)
      mux = mean(X1)
      sdx = sd(X1)
      outx = mux + (outlier*sdx) # function for outlier
      X = c(X1,outx)
      muy = mean(Y1)
      sdy = sd(Y1)
      outy = muy + (outlier*sdy)
      Y = c(Y1, outy)
      return(data.frame(X,Y))

    }
    else{
      X1 = rnorm(numPoints,value,valueB)
      Y1 = rnorm(numPoints,rnorm(1)*X1,rgamma(1,1)*valueB)
      mux = mean(X1)
      sdx = sd(X1)
      outx = mux - (outlier*sdx)
      X = c(X1,outx)
      muy = mean(Y1)
      sdy = sd(Y1)
      outy = muy - (outlier*sdy)
      Y = c(Y1, outy)
      return(data.frame(X,Y))


    }
  }
  else if (difficulty == 1){
    X = rnorm(numPoints,value,valueB)
    Y = rnorm(numPoints,rnorm(1)*X,rgamma(1,1)*valueB)
    return(data.frame(X,Y))
  }

}

check_submission <- function(data, guess){
  actual <- cor(data$X, data$Y)
  resp <- function(msg, success){
    message <- if (success){
     paste(msg, 'The true correlation was', signif(actual, 2))
    } else {
      msg
    }
    list(message, success)
  }
  sgn_incorrect <- sign(actual) != sign(guess)
  gap = abs(actual - guess)
  r <- dplyr::case_when(
    sgn_incorrect ~ resp('Check the sign!', FALSE),
    gap < 0.1 ~ resp('Awesome!', TRUE),
    gap < 0.2 ~ resp('Pretty Close! You can do it.', FALSE),
    TRUE ~ resp("Try again! You can get closer!", FALSE)
  )
  names(r) <- c('message', 'success')
  return(r)
}

data <- generate_data(1, 50)

sidebar <- function(){
  tagList(
    sliderInput(
      inputId = 'guess',
      label = 'The correlation is ...',
      value = 0.5,
      min = -1,
      max = 1,
      step = 0.01
    )
  )
}


main <- function(){
  tagList(
    plotOutput('plot')
  )
}

ui <- navbarPage(
  title = "Guess the Correlation!",
  theme = shinythemes::shinytheme('cosmo'),
  tabPanel("Home",
    sidebarLayout(
      sidebarPanel(sidebar(), non_coding_ui('feedback')),
      mainPanel(main())
    )
  )
)

server <- function(input, output, session){
  output$plot <- renderPlot({
    ggplot(data = data, aes(x = X, y = Y)) +
      geom_point()
  })
  feedback <- reactive({
    check_submission(data, input$guess)
  })
  shiny::callModule(non_coding, 'feedback', feedback)
}

shinyApp(ui = ui, server = server)
