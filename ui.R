library(shiny)
library(DT)
#library(shinyTime)

ui <- fluidPage(
    h1("Bitshares Witness Performance"),
    verbatimTextOutput(outputId = "last_update"),
    p(strong("Please select witness or witness from table to highlight feed trace")),
    DT::dataTableOutput(outputId = "witness_summary"),
    #uiOutput("select_witness"),
    #p(strong("Missed Blocks:")),
    #verbatimTextOutput(outputId = "missed_block_summary"),
    uiOutput("reactive_slider"),
    p(strong("Feed History:")),
    radioButtons(inputId = "asset_choice",label = "Choose asset:",choices = c("USD","CNY","BTC"),inline = TRUE),
    plotOutput(outputId = "feed_trace",click = "plot_select")
    
    #verbatimTextOutput(outputId = "info")
)