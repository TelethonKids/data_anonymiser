


library(shiny)
library(shinydashboard)
library(shinyjs)
library(gtsummary)

header <-
  dashboardHeader(title = "Data Anonymizer - Obscure your data")
sidebar <- dashboardSidebar(
  tags$div(
    "You can drag and drop or click browse then locate your file to upload it to the Data Anonymizer",
    style = "margin-bottom: 20px; padding: 12px; color: #555;"
  ),
  fileInput("file", "Choose CSV or Excel File", accept = c(".csv", ".xlsx")),
  numericInput("rows", "Number of rows to generate", 100),
  uiOutput("column_selector"),
  actionButton("go", "Generate")
)
body <- dashboardBody(useShinyjs(), # Initialize shinyjs
                      tabsetPanel(
                        tabPanel("Download",
                                 hidden(
                                   div(
                                     tags$div("Your obscured data file is NOW READY for download.", style = "color: green; padding-bottom: 12px; font-weight: bold;"),
                                     id = "downloadDiv",
                                     downloadButton("downloadData", "Download")
                                   )
                                 ),
                                 tags$div(
                                   HTML(
                                     '<img src="https://pbs.twimg.com/profile_images/893344513711681536/Is0TqvmY_400x400.jpg" alt="Description of Image" style="float: right; width="200" height="200">'
                                   ),
                                   HTML(
                                     "<br><i>(Click the three dashes (top left) to open the side menu)</i><br><br>
                                     The purpose of this app is to obscure your data so you can share it with confidence.<br><br>
             Relationships will not be maintained between variables, however, the obscured data will follow a similar range (of distribution) and number of categories (for categorical data) to your original data.<br><br>
             This means you will be able to provide the resulting dataset to a colleague (virtual or otherwise) to get them to assist you with code to visualise or analyse your data - without them seeing your actual data.<br><br>"
                                   ),
             HTML(
               '<p>Here is what the Data Anonymizer will do to your data:</p>
<ul>
    <li><strong>Column names:</strong> These will all be replaced with a generic name of the form “VAR_1”, “VAR_2” etc</li>
    <li><strong>Continuous variables</strong>
        <ul>
            <li><strong>15 or fewer unique values: </strong>These will be randomly (evenly) replaced with integers 0 through to the n (where n is the number of unique values within that variable).</li>
            <li><strong>More than 15 unique values: </strong>Will be replaced with random normally distributed data that has the same mean and standard deviation as the original data.</li>
        </ul>
    </li>
    <li><strong>Date variables:</strong> The min and max date will be found within the provided data, then uniformly distributed dates between that min and max date will be returned.</li>
    <li><strong>Categorical variables (includes dichotomous variables)</strong>
        <ul>
            <li><strong>15 or fewer unique categories: </strong>These will be randomly (evenly) replaced with letters “A” through "O"</li>
            <li><strong>More than 15 unique categories: </strong><i>(For example studyIDs, names, addresses etc) </i>these will be replaced with a random string of length 6 (may or may not be unique).</li>
        </ul>
    </li>
</ul><br><br>
               Version: 2024-07-19'
             )
                                 )),
tabPanel(
  "Example",
  HTML('<br>'),
  tags$div("Below is some example output from the app."),
  HTML(
    '<img src="example_img_2.png" alt="Example output" style="float: left; padding: 12px; width="400" height="400">'
  ),
  HTML(
    '<img src="example_img.png" alt="Example output" style="float: left; clear:left; padding: 12px; width="400" height="400">'
  )
),
tabPanel(
  "Report",
  tags$div("Comparison report will be populated after 'Generate' is clicked."),
  fluidRow(column(6, uiOutput(
    "originalDataReport"
  )),
  column(6, uiOutput(
    "anonymizedDataReport"
  )))
)
                      ),
fluidRow(
  column(12, align="center",
         tags$div("Developed by the Telethon Kids Institute Biometrics Group, 2024.", 
                  style = "margin-bottom: 20px; padding-top: 20px; clear:left; color: #555;")
  )))

ui <- dashboardPage(header, sidebar, body)
