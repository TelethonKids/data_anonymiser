
library(shiny)
library(shinydashboard)
library(shinyjs)
library(tidyverse)
library(stringi) # For generating random strings
library(readr) # For read_csv
library(readxl) # For reading Excel files
library(lubridate) # For handling date operations
library(gtsummary)

server <- function(input, output, session) {
  data <- reactiveVal()
  anonymized_data <- reactiveVal()
  
  observe({
    req(input$file)
    if (grepl("\\.csv$", input$file$name)) {
      df <- readr::read_csv(input$file$datapath) %>% as_tibble()
    } else if (grepl("\\.xlsx$", input$file$name)) {
      df <- readxl::read_excel(input$file$datapath) %>% as_tibble()
    } else {
      df <- tibble()
    }
    data(df)
    updateSelectInput(session, "columns", choices = names(df), selected = names(df))
  })
  
  output$column_selector <- renderUI({
    req(data())
    selectInput("columns", "Select columns to keep", choices = names(data()), multiple = TRUE, selected = names(data()))
  })
  
  observeEvent(input$go, {
    req(data())
    df <- data()[, input$columns, drop = FALSE] %>% as_tibble()
    
    colnames(df) <- paste0("VAR_", seq_along(df))
    
    anonymized_df <- df %>%
      mutate(across(where(~is.numeric(.) && length(unique(.)) <= 15), ~sample(0:(length(unique(na.omit(.)))-1), n(), replace = TRUE))) %>%
      mutate(across(where(~is.numeric(.) && length(unique(.)) > 15), ~round(rnorm(n(), mean(., na.rm = TRUE), sd(., na.rm = TRUE)), 2))) %>%
      mutate(across(where(is.factor), ~factor(sample(LETTERS[1:length(unique(.))], n(), replace = TRUE)))) %>%
      mutate(across(where(~is.character(.) && length(unique(.)) <= 15), ~factor(sample(LETTERS[1:length(unique(.))], n(), replace = TRUE)))) %>%
      mutate(across(where(~is.character(.) && length(unique(.)) > 15), ~stri_rand_strings(n(), 6))) %>%
      mutate(across(where(is.Date), function(x) {
        start_date <- min(x, na.rm = TRUE)
        end_date <- max(x, na.rm = TRUE)
        days_diff <- as.integer(end_date - start_date)
        sample_dates <- start_date + days(sample(0:days_diff, n(), replace = TRUE))
        return(sample_dates)
      }))
    
    if(nrow(df) > input$rows) {
      anonymized_df <- anonymized_df %>% slice_sample(n = input$rows)
    }
    
    anonymized_data(anonymized_df)
    
    output$originalDataReport <- renderUI({
      req(data())
      original_data <- data()[, input$columns, drop = FALSE]
      original_report <- original_data %>% 
        select(where(~length(unique(.)) <= 15)) %>% 
        tbl_summary()
      gt_output_original <- as_gt(original_report)
      gt_output_original
    })
    
    output$anonymizedDataReport <- renderUI({
      req(anonymized_data())
      new_data <- anonymized_data()
      anonymized_report <- new_data %>% 
        select(where(~length(unique(.)) <= 15)) %>% 
        tbl_summary()
      gt_output_anonymized <- as_gt(anonymized_report)
      gt_output_anonymized
    })
    
    shinyjs::show("downloadDiv")
  })
  
  output$downloadData <- downloadHandler(
    filename = function() { "anonymized_data.csv" },
    content = function(file) {
      write.csv(anonymized_data(), file, row.names = FALSE)
    }
  )
}
