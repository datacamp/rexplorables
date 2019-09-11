library(shiny)
library(dplyr)
library(ggplot2)
library(rexplorables)

#' Copied over from https://juliasilge.shinyapps.io/power-app/
generate_data <- function(baseline, power = 80, signif_level = 5){
  seq(1000, 1e4, by = 100) %>%
    purrr::map_df(~power.prop.test(
      p1 = baseline / 100,
      p2 = NULL,
      n = .x,
      power = power / 100,
      sig.level = signif_level / 100
    ) %>%
      broom::tidy()) %>%
    mutate(effect = (p2 / p1 - 1))
}

check_submission <- function(actual, guess){
  resp <- function(msg, success){
    message <- if (success){
      paste(msg, 'The sample size required is ', actual)
    } else {
      msg
    }
    list(message, success)
  }
  r <- case_when(
    guess == actual ~ resp("Awesome!", TRUE),
    TRUE ~ resp("Try Again! You are close", FALSE)
  )
  names(r) <- c('message', 'success')
  r
}

sidebar <- function() {
  tagList(
    sliderInput("sample_size", "Sample Size",
      min = 1000, max = 10000,
      value = 1000, step = 500,
    ),
    sliderInput("baseline", "Baseline conversion rate",
      min = 1, max = 50,
      value = 5, post = "%"
    ),
    sliderInput("power", "Power threshold",
      min = 1, max = 99,
      value = 80, post = "%"
    ),
    sliderInput("signif_level", "Significance level",
      min = 1, max = 20,
      value = 5, post = "%"
    )
  )
}

main <- function(){
  tagList(
    plotOutput('plot'),
    tags$hr(),
    uiOutput("response")
  )
}

ui <- navbarPage(
  title = "Sample Size Calculator",
  theme = shinythemes::shinytheme('cosmo'),
  tabPanel("Home",
    sidebarLayout(
      sidebarPanel(sidebar(), non_coding_ui('feedback')),
      mainPanel(main())
    )
  )
)

server <- function(input, output, session){
  data <- reactive({
    generate_data(input$baseline)
  })
  output$plot <- renderPlot({
    ggplot(data = data(), aes(x = n, y = effect)) +
      geom_line() +
      scale_y_continuous(
        labels = scales::percent_format(accuracy = 1)) +
      labs(
        title = 'MDE vs. Sample Size',
        x = 'Sample Size',
        y = 'Minimum Detectable Effect'
      ) +
      geom_vline(
        xintercept = input$sample_size,
        linetype = 'dotted'
      )
  })
  feedback <- reactive({
    check_submission(4000, input$sample_size)
  })
  callModule(non_coding, 'feedback', feedback)
}

shinyApp(ui = ui, server = server)
