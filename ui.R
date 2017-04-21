library(shiny)
#library(shinyTime)

ui <- fluidPage(
        h1("Witness Statistics"),
        uiOutput("select_witness"),

    verbatimTextOutput(outputId = "last_update"),
    verbatimTextOutput(outputId = "missed_block_summary"),
    verbatimTextOutput(outputId = "check_select_witness"),
    #radioButtons(inputId ="topic_of_interest", label = "Select Topic", choices = c("User Activity", "Network Activity"), selected = "Network Activity"),
    
    #dateInput(inputId = "date" , label = "choose a date",value = "2017-3-27"),
#    uiOutput("reactive_date"),
    
    uiOutput("reactive_slider"),


#     fixed slider which works

#     sliderInput("time_selections", 
#                 "Choose Date Range:", 
#                 min = as.POSIXct(paste ("2016-6-25"," 12:00:00"),tz = "GMT"),
#                 max = as.POSIXct(paste("2016-6-30"," 23:59:59"),tz = "GMT"),
#                 value = c(as.POSIXct(paste("2016-6-25"," 12:00:00"),tz = "GMT"),as.POSIXct(paste("2016-6-25"," 22:30:00"),tz= "GMT")),
#                 timezone = "+0000",
#                 timeFormat = "%b %e %H:%M", ticks = T, animate = F,width = '100%',step = 300
#     ),
    
    
    #uncomment to show default selected witnesses
    #uiOutput("select_witnesses"),
    
#    radioButtons(inputId = "tx_ops_select",label = "Txs or ops", choices = c("txs","ops"),selected = "txs"),
    

#checkboxGroupInput(inputId = "select_witnesses",label = "Select witnesses:",req(c(feed_history,active_witnesses)),choices = levels(as.factor(feed_history$name)),selected = active_witnesses$name,inline = TRUE),



#     conditionalPanel(
#         condition = "input.filter_selection[1] == 'witness'||input.filter_selection[0] == 'witness' ",
#         selectInput(inputId = "witness_selection",label = "Choose a witness", choices = witness_list$name,selected = "lafona2")
#     ),
    plotOutput(outputId = "feed_trace",click = "plot_select")
    #verbatimTextOutput("info")

    
)