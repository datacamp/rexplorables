# rexplorables

<!-- badges: start -->
<!-- badges: end -->

The goal of `rexplorables` is to provide a set of utility functions to author and use `Explorable with Multiple Choice` and `Explorable` exercises.

## Installation

You can install `rexplorables` from github with:

``` r
remotes::install_github("rexplorables")
```

## Authoring

### ExplorableExercise

__Explorable__ exercises are one of the newest types of exercises in our courses. In this type of exercise, learners interact with a web app and complete a given task. For example, this exercise type can be used to ask learners to view a scatterplot, and use a slider to guess the correlation coefficient. This exercise type can support arbitrary types of user interactions, and hence is extremely flexible.

Let us go through the steps required to author a shiny-app that can be used in a ExplorableExercise. For the sake of simplicity, we will build a shiny-app that requires users to respond to a question by typing their answer into a text box.

#### Step 1: Write Shiny App

The first step is to write the raw shiny-app that captures the user-interactions. For this app, all we need is to display the question, and a textbox for the user to type their answer into.

```r
# Load Libraries
library(shiny)
library(rexplorables)

# UI
ui <- fluidPage(
  textInput("us_capital", "What is the capital of the US?"),
)

# Server
server <- function(input, output, session){
 
}

shinyApp(ui = ui, server = server)
```

#### Step 2: Write SCT

The second step is to write an SCT function, that takes the user’s response(s) as input(s),  checks its correctness, and provides appropriate feedback.

```r
check_submission <- function(response){
  if (response == 'Washington DC'){
    list(message = 'Bingo!', success = TRUE)
  } else {
    list(message = 'Sorry! Try Again', success = FALSE)
  }
}
```


#### Step 3: Integrate SCT

The next step is to integrate the SCT function into the shiny-app, so we can provide users with feedback. The rexplorables package provides a handy shiny module named non_coding_ui, that makes this easy.

1. Create a reactive variable that uses the SCT to compute the feedback to provide to the user.
2. Use the `non_coding` module by calling `non_coding_ui` in the UI, and the `callModule` function in the server.

```r
# UI
ui <- fluidPage(
  textInput("us_capital", "What is the capital of the US?"),
  non_coding_ui(NULL)
)

# Server
server <- function(input, output, session){
  feedback <- reactive({check_submission(input$us_capital)})
  callModule(non_coding, NULL, feedback)
}
```

If you run this shiny-app now, you will notice that it adds a submit button, and provides appropriate feedback when you click on it.

```r
# Load Libraries
library(shiny)
library(rexplorables)

# SCT
check_submission <- function(response){
  if (response == 'Washington DC'){
    list(message = 'Bingo!', success = TRUE)
  } else {
    list(message = 'Sorry! Try Again', success = FALSE)
  }
}

# UI
ui <- fluidPage(
  textInput("us_capital", "What is the capital of the US?"),
  non_coding_ui(NULL)
)

# Server
server <- function(input, output, session){
  feedback <- reactive({check_submission(input$us_capital)})
  callModule(non_coding, NULL, feedback)
}

shinyApp(ui = ui, server = server)
```

When you run this shiny-app on DataCamp, the non_coding module recognizes it and automatically switches to use the Submit Button at the bottom of the screen, and provides feedback in the panel on the left-side, just like any other DataCamp exercise.

#### Step 4: Upload App

Now that your app is complete, zip it up, and upload it to the Teach Editor as a dataset. Once you upload it, you will get a link to the app.

#### Step 5: Use App in Exercise

The final step is to use it in your exercise.

```r
url <- "https://assets.datacamp.com/production/repositories/4738/datasets/831b9f9bded1a54617af3d67e2d4c01324e79396/hello_world.zip"
rexplorables::copy_explorables(url)
displayPage('hello_world/')
```

Note that this step would download the exercise to the docker container and serve the shiny app. It avoids a build step and hence is great during development, but as it involves a download step, can be slow for production. Hence, in production, it is recommended that you directly download the explorables into the course container by copying the first two lines of code to `requirements.R`.
