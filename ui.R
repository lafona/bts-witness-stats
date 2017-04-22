library(shiny)
#library(shinyTime)

ui <- fluidPage(
    h1("Bitshares Witness Statistics"),
    verbatimTextOutput(outputId = "last_update"),
    uiOutput("select_witness"),
    p(strong("Missed Blocks:")),
    verbatimTextOutput(outputId = "missed_block_summary"),
    p(strong("Feed History:")),
    plotOutput(outputId = "feed_trace",click = "plot_select"),
    uiOutput("reactive_slider")
)