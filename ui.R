library(shiny)
library(DT)
#library(shinyTime)

ui <- fluidPage(
    h1("Bitshares Witness Performance"),
    verbatimTextOutput(outputId = "last_update"),
    DT::dataTableOutput(outputId = "witness_summary"),
    #uiOutput("select_witness"),
    #p(strong("Missed Blocks:")),
    #verbatimTextOutput(outputId = "missed_block_summary"),
    p(strong("Feed History:")),
    plotOutput(outputId = "feed_trace",click = "plot_select"),
    uiOutput("reactive_slider")
    #verbatimTextOutput(outputId = "info")
)