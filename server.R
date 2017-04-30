library(shiny)
library(ggplot2)
library(data.table)
library(scales)
library(dtplyr)
library(dplyr)
library(DT)


server <- function(input, output) {
    feed_data<- reactive({
        invalidateLater(millis = 300000)
        load(file = "./data/app_files/feed_history.RData")
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
        sliderInput("time_selections", 
                    "Timeframe for Feed History:", 
                    min = (max(feed_data()$last_block_time))-14400*6,
                    max = max(feed_data()$last_block_time),
                    value = c((max(feed_data()$last_block_time))-7200,max(feed_data()$last_block_time)),
                    timezone = "+0000",
                    timeFormat = "%b %e %H:%M", ticks = T, animate = F,width = '90%',step = 300
        )
    })
    
    table_data<- reactive({
        active_witnesses()
        current_time<-max(missed_blocks()$timestamp)
        #missed_blocks() %>% filter(witness_id %in% active_witnesses()$account_id)
        missed_blocks() %>% group_by(witness_id) %>% summarise(missed = max(total_missed)) ->total_missed
        missed_blocks() %>% group_by(witness_id) %>% filter(timestamp<(current_time-3600))%>%summarise(missed60 = max(total_missed)) ->hourly_missed
        missed_blocks() %>% group_by(witness_id) %>% filter(timestamp<(current_time-3600*24))%>%summarise(missed24 = max(total_missed)) ->daily_missed
        missed_blocks() %>% group_by(witness_id) %>% filter(timestamp<(current_time-3600*24*7))%>%summarise(missed7 = max(total_missed)) ->weekly_missed
        missed_by_time <-left_join(total_missed, hourly_missed)
        missed_by_time <-left_join(missed_by_time, daily_missed)
        missed_by_time <-left_join(missed_by_time, weekly_missed)
        filtered_missed<-left_join(active_witnesses(),missed_by_time)
        filtered_missed$witness_id<-NULL
        filtered_missed$account_id<-NULL
        filtered_missed$'missed in last hour'<-filtered_missed$missed-filtered_missed$missed60
        filtered_missed$'missed in last 24 hours '<-filtered_missed$missed-filtered_missed$missed24
        filtered_missed$'missed in last week'<-filtered_missed$missed-filtered_missed$missed7
        filtered_missed$missed<-NULL
        filtered_missed$missed60<-NULL
        filtered_missed$missed24<-NULL
        filtered_missed$missed7<-NULL
        filtered_missed
    })
    output$witness_summary<-DT::renderDataTable(table_data(),options = list(
        pageLength = 30
    ),server = FALSE)
    output$select_witness<- renderUI({
        selectInput(inputId = "select_witness",
                           label = "Select witness:",
                           choices = active_witnesses()$name
        )
     })                
    output$select_witnesses<- renderUI({
        checkboxGroupInput(inputId = "select_witnesses",
                           label = "Select witnesses:",
                           choices = levels(as.factor(feed_data()$name)),
                           selected = active_witnesses()$name,
                           inline = TRUE)
    })
    
    missed_block_data<-reactive({
        active_witnesses() %>% dplyr::filter(name %in% input$select_witness)->chosen_witness_info
        missed_blocks() %>% dplyr::filter(witness_id %in% chosen_witness_info$witness_id) -> missed_block_history
        
        #1 hour
        missed_block_history %>% dplyr::filter(timestamp >= (max(missed_block_history$timestamp)-(1*3600))) -> one_hour_old_missed_count
        missed_in_one<-max(missed_block_history$total_missed)-min(one_hour_old_missed_count$total_missed)
        
        #6 hours
        missed_block_history %>% dplyr::filter(timestamp >= (max(missed_block_history$timestamp)-(6*3600))) -> six_hours_old_missed_count
        missed_in_six<-max(missed_block_history$total_missed)-min(six_hours_old_missed_count$total_missed)
        
        #calculate missed blocks for 24 hours
        missed_block_history %>% dplyr::filter(timestamp >= (max(missed_block_history$timestamp)-(24*3600))) -> twentyfour_hours_old_missed_count
        missed_in_twentyfour<-max(missed_block_history$total_missed)-min(twentyfour_hours_old_missed_count$total_missed)
        
        #1 week
        missed_block_history %>% dplyr::filter(timestamp >= (max(missed_block_history$timestamp)-(7*24*3600))) -> week_old_missed_count
        missed_in_week<-max(missed_block_history$total_missed)-min(week_old_missed_count$total_missed)
        
        missed_block_data<-c(missed_in_one,missed_in_six, missed_in_twentyfour, missed_in_week)
    })
    
    output$last_update<-renderText({paste("Contains data from",min(feed_data()$last_block_time),"to",max(feed_data()$last_block_time))})
    output$check_select_witness<-renderText({input$select_witness})
    output$missed_block_summary<-renderText({paste("last hour:",as.character(missed_block_data()[1]),"   last 6 hours:",as.character(missed_block_data()[2]),"    last 24 hours:",as.character(missed_block_data()[3]))
        })
    
    
    filtered_data<- reactive({
        feed_data()%>%dplyr::filter(last_block_time >= input$time_selections[1]) %>%dplyr::filter(last_block_time <= input$time_selections[2]) ->feed_data_selection
        feed_data_selection %>% dplyr::filter(name %in% active_witnesses()$name)->feed_data_selection
    })

    output$feed_trace<-renderPlot({
        
        ggplot(data = filtered_data(), aes(x = last_block_time, y = ratio, colour = name))+
            geom_line()+
            #geom_line(data = filtered_data() %>% dplyr::filter(name %in% input$select_witness),aes(x = last_block_time, y = ratio),size = 2) +
            geom_line(data = filtered_data() %>% dplyr::filter(name %in% table_data()[input$witness_summary_rows_selected,]$name),aes(x = last_block_time, y = ratio),size = 2) +
            labs(title="Price Feeds for USD",x = "time")
    })
    output$info<- renderPrint(nearPoints(as.data.frame(filtered_data()), input$plot_select)$name)
    #output$info<- renderPrint(nearPoints(as.data.frame(filtered_data()), input$plot_select)$name)
}