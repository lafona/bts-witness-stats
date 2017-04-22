library(shiny)
library(ggplot2)
library(data.table)
library(scales)
library(feather)
library(dtplyr)
library(dplyr)

#setkey(feed_data(),last_block_time)

#setwd("~/Applications/Graphene/Bitshares/graphs/Feed_History/app/")
server <- function(input, output) {
    feed_data<- reactive({
        invalidateLater(millis = 300000)
        load(file = "./data/app_files/feed_history.RData")
        #load("./appdata.RData")
        #active_witnesses<<-active_witnesses
        #feed_history<<-feed_history
        #witness_list<<-witness_list
        #setkey(feed_history,last_block_time)
        feed_history
    })
    active_witnesses<-reactive({
        invalidateLater(millis = 300000)
        load(file = "./data/app_files/active_witnesses.RData")
        active_witnesses
    })
    witness_list<- reactive({
        invalidateLater(millis = 300000)
        load(file = "./data/app_files/witness_list.RData")
        witness_list
    })
    missed_blocks<- reactive({
        invalidateLater(millis = 300000)
        load(file = "./data/app_files/missed_blocks.RData")
        missed_blocks
    })
    output$reactive_date <- renderUI({
        dateInput(inputId = "date" , label = "choose a date",value = max(feed_data()$last_block_time))
    })
    
    output$reactive_slider <- renderUI({
        date <- input$date
        #checkboxGroupInput("cities", "Choose Cities", cities)
        sliderInput("time_selections", 
                    "Choose Date Range:", 
                    
                    #min = as.POSIXct(input$date,tz = "GMT"),
                    #max = as.POSIXct(input$date+1,tz = "GMT"),
                    min = (max(feed_data()$last_block_time))-14400*6,
                    max = max(feed_data()$last_block_time),
                    #value = c(as.POSIXct(input$date+0.25,tz = "GMT"),as.POSIXct(input$date+0.5,tz = "GMT")
                    value = c((max(feed_data()$last_block_time))-7200,max(feed_data()$last_block_time)),
                    timezone = "+0000",
                    timeFormat = "%b %e %H:%M", ticks = T, animate = F,width = '100%',step = 300
                    #timeFormat = "%b %e %H:%M", ticks = T, animate = F
        )
    })
    
    
    output$select_witness<- renderUI({
        #temp_feed_data<-feed_data()
        #temp_active_witnesses<-active_witnesses()
        selectInput(inputId = "select_witness",
                           label = "Select witness:",
                           choices = active_witnesses()$name
        )
     })                
    output$select_witnesses<- renderUI({
        #temp_feed_data<-feed_data()
        #temp_active_witnesses<-active_witnesses()
        checkboxGroupInput(inputId = "select_witnesses",
                           label = "Select witnesses:",
                           choices = levels(as.factor(feed_data()$name)),
                           selected = active_witnesses()$name,
                           inline = TRUE)
    })
    
    missed_block_data<-reactive({
        active_witnesses() %>% dplyr::filter(name %in% input$select_witness)->chosen_witness_info
        missed_blocks() %>% dplyr::filter(witness_id %in% chosen_witness_info$witness_id) -> missed_block_history
        missed_block_history %>% dplyr::filter(timestamp >= (max(missed_block_history$timestamp)-(24*3600))) -> twentyfour_hours_old_missed_count
        missed_in_twentyfour<-max(missed_block_history$total_missed)-min(twentyfour_hours_old_missed_count$total_missed)
        
        missed_block_history %>% dplyr::filter(timestamp >= (max(missed_block_history$timestamp)-(6*3600))) -> six_hours_old_missed_count
        missed_in_six<-max(missed_block_history$total_missed)-min(six_hours_old_missed_count$total_missed)
        
        missed_block_history %>% dplyr::filter(timestamp >= (max(missed_block_history$timestamp)-(7*24*3600))) -> week_old_missed_count
        missed_in_week<-max(missed_block_history$total_missed)-min(week_old_missed_count$total_missed)
        
        #missed_block_data<-c(missed_in_twentyfour,missed_in_six)
        missed_block_data<-c(missed_in_six,missed_in_twentyfour, missed_in_week)
    })
    
    output$last_update<-renderText({paste("Contains data from",min(feed_data()$last_block_time),"to",max(feed_data()$last_block_time))})
    output$check_select_witness<-renderText({input$select_witness})
    output$missed_block_summary<-renderText({paste("last six hours: ",as.character(missed_block_data()[1]),"  last 24 hours: ",as.character(missed_block_data()[2]),"   last week: ",as.character(missed_block_data()[3]))
        })
    
    
    filtered_data<- reactive({
        feed_data()%>%dplyr::filter(last_block_time >= input$time_selections[1]) %>%dplyr::filter(last_block_time <= input$time_selections[2]) ->feed_data_selection
        #feed_data()%>%dplyr::filter(last_block_time >= ((max(feed_data()$last_block_time))-7200)) ->feed_data_selection
        feed_data_selection %>% dplyr::filter(name %in% active_witnesses()$name)->feed_data_selection
    })

    output$feed_trace<-renderPlot({
        
        ggplot(data = filtered_data(), aes(x = last_block_time, y = ratio, colour = name))+
            geom_line()+
            geom_line(data = filtered_data() %>% dplyr::filter(name %in% input$select_witness),aes(x = last_block_time, y = ratio),size = 2) +
            labs(title="Price Feeds for USD",x = "time")
        #ggplot(data = Day_totals,aes(x = datetime,y = txs))+geom_bar(stat = "identity")+theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))+labs(title="Transactions Processed per Block",y = "# transactions")
    })
    
    #output$info<- renderPrint(nearPoints(filtered_data(), input$plot_click, xvar = "last_block_time", yvar = "ratio"))
    output$info<- renderPrint(nearPoints(as.data.frame(filtered_data()), input$plot_select)$name)
}