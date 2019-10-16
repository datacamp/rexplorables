### _Market Basket Analysis in R: Case Study in using explorable exercise with MCQ_
##### Author: Adel Nehme

##### Context:

In the course _Market Basket Analysis in R,_ students are tasked in analyzing transactional datasets and compute associations between different items. The most commonly used package to perform such analysis is in the [arules](https://www.rdocumentation.org/packages/arules/versions/1.6-4) package, which takes in datasets of the class `transactions` and `rules` and computes interesting relationships between transactions and items in a basket. A companion package used in the course, named [arulesViz](https://www.rdocumentation.org/packages/arulesViz/versions/1.3-3), lets students visualize these transactions and rules. One function used in this package is the `ruleExplorer()` function which takes in a `rules` object and outputs a shiny app with a variety of analytics. 

It was a great candidate to be displayed as an explorable with MCQ exercise so that students are prompted to interact with the dashboard while responding to questions as such:

https://www.loom.com/share/34ac9377d26045e79a10afa29215c812


##### How to:

Even though this process is given in the GitHub documentation of the new exercise types, I will be outlining the steps I took in order to get this particular app running.

1) Make sure the course has a shiny base-image in the `course.yml` file.
2) Make sure the `rexplorables` package is installed in the `requirements.R` file.
3) Make sure XML is installed in the `requirements.sh` file.
4) Launch local RStudio environment to test out the shiny app.
5) Create a folder to house your app - name this folder `chX_exY` for better tracking in case you want to have more than one Explorable exercise in the course.
6) Add an `app.R` file in this folder.
7) Load the code needed to launch the app from A to Z (preprocessing data, to inserting the data in a shiny app) in the `app.R` file while making sure the `rexplorables` package is loaded in the file. <br>
  Note that the `ruleExplorer()` function takes in a `rules` object and outputs a shiny app. The explorable exercise types **do not require** any changes to the source code to adapt any of the original source code of the function, and the code I used was just the following: <br>
  ```R
  # Loading required packages - including rexplorables
library(rexplorables)
library(arules)
library(tidyverse)
library(arulesViz)

#### Transformations needed to make sure association rules are created

Online_Retail_2011_Q1 = read.csv("https://assets.datacamp.com/production/repositories/5023/datasets/8759a37fd5570a976159ff8fcf97af521bd3c778/Online_Retail_2011_Q1_sub.csv", header = TRUE)

Online_Retail_clean = Online_Retail_2011_Q1 %>% filter(complete.cases(.))

data_list = split(Online_Retail_clean$Description, Online_Retail_clean$InvoiceNo)
Online_trx = as(data_list, "transactions")

rules_online = apriori(Online_trx,
                       parameter = list(supp = 0.01, conf = 0.8, minlen = 2))

#### Actual code that launches shiny app
ruleExplorer(rules_online)
```
8) After having made sure the app works fine in your local set up, save it in the `chX_exY` folder and zip the folder - for simplicity, name the zip file `chX_exY` as well.
9) Upload the zip file to teach, and implement the following code in the PEC of the explorable exercise of choice: <br>
```R
# Link to the uploaded zip file in assets
url <- "https://assets.datacamp.com/production/repositories/5023/datasets/04f991c1cf726753a3ba0b98c4c2d10a16bb7850/ch1_ex2.zip"

# Copy the URL as an explorable exercise
rexplorables::copy_explorables(url)

# Display app.R file inside of the explorable folder
displayPage(“ch1_ex2/')

```

**Note that it's preferred to copy-paste the following lines of code in the `requirements.R` file before soft launch to make sure the app is saved in the docker image and the web app won't have to be downloaded each time** 

```R
# Link to the uploaded zip file in assets
url <- "https://assets.datacamp.com/production/repositories/5023/datasets/04f991c1cf726753a3ba0b98c4c2d10a16bb7850/ch1_ex2.zip"

# Copy the URL as an explorable exercise
rexplorables::copy_explorables(url)
```


If you have any questions on how to get this done, feel free to slack me or email me! 

