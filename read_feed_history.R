library(jsonlite)
library(data.table)
library(dplyr)
library(dtplyr)

getwd()
# feed_history<- fromJSON("./feed_history.txt")
# feed_history<- data.table(feed_history)
# colnames(feed_history)<-c("last_block_time","account_id","feedtime","base_usd","quote_bts")
# 
# feed_history$ratio<-as.numeric(feed_history$base_usd)/as.numeric(feed_history$quote_bts)
# feed_history$last_block_time<-gsub(pattern = "T",replacement = " ",x = feed_history$last_block_time)
# feed_history$last_block_time<-as.POSIXct(feed_history$last_block_time,tz = "GMT")
# feed_history$feedtime<-gsub(pattern = "T",replacement = " ",x = feed_history$feedtime)
# feed_history$feedtime<-as.POSIXct(feed_history$feedtime,tz = "GMT")
# 
# witness_list<-fromJSON("./witness_list.txt")
# witness_list<-data.table(witness_list)
# colnames(witness_list)<-c("name","witness_id","account_id")
# 
# feed_history<-dplyr::left_join(feed_history,witness_list)


#setwd("~/Applications/Graphene/Bitshares/graphs/Feed_History/")

filenames <- list.files("./data/feed_history/", pattern="*.txt", full.names=TRUE)
ag_feed_history = {}
for (name in filenames){
    feed_history<- fromJSON(name)
    feed_history<- data.table(feed_history)
    colnames(feed_history)<-c("last_block_time","account_id","feedtime","base_usd","quote_bts","block_num","asset")
    
    feed_history$ratio[feed_history$asset=="USD"]<-as.numeric(feed_history$base_usd[feed_history$asset=="USD"])/as.numeric(feed_history$quote_bts[feed_history$asset=="USD"])*10
    feed_history$ratio[feed_history$asset=="CNY"]<-as.numeric(feed_history$base_usd[feed_history$asset=="CNY"])/as.numeric(feed_history$quote_bts[feed_history$asset=="CNY"])*10
    feed_history$ratio[feed_history$asset=="BTC"]<-as.numeric(feed_history$base_usd[feed_history$asset=="BTC"])/as.numeric(feed_history$quote_bts[feed_history$asset=="BTC"])/1000
    
    feed_history$last_block_time<-gsub(pattern = "T",replacement = " ",x = feed_history$last_block_time)
    feed_history$last_block_time<-as.POSIXct(feed_history$last_block_time,tz = "GMT")
    feed_history$feedtime<-gsub(pattern = "T",replacement = " ",x = feed_history$feedtime)
    feed_history$feedtime<-as.POSIXct(feed_history$feedtime,tz = "GMT")
    

    #loads files into a list of dataframes
    #ldf<-lapply(filenames, read.delim)
    #nested_file_data<-lapply(filenames, fromJSON)
    
    #combines dataframes from individual files into one big data table
    ag_feed_history<-rbind(ag_feed_history,feed_history)
    #agglist<-do.call(rbind, nested_file_data)
}

feed_history<-ag_feed_history
rm(ag_feed_history)

witness_list<-fromJSON("./data/witness_list/witness_list.txt")
witness_list<-data.table(witness_list)
colnames(witness_list)<-c("name","witness_id","account_id")

feed_history<-dplyr::left_join(feed_history,witness_list)

# info <-fromJSON("./active_witnesses.txt")
# witness_list%>%dplyr::filter(witness_id %in% info$active_witnesses)->active_witnesses

info <-fromJSON("./data/witness_list/active_witnesses.txt")
witness_list%>%dplyr::filter(witness_id %in% info)->active_witnesses

mb_filenames <- list.files("./data/missed_blocks/", pattern="*.txt", full.names=TRUE)
missed_blocks<-fromJSON(max(mb_filenames))

ag_missed_blocks<-{}
for (name in mb_filenames){
    missed_blocks<- fromJSON(name)
    missed_blocks<-data.table(missed_blocks)
    colnames(missed_blocks)<-c("witness_id","account_id","total_missed","timestamp","block_num")
    
    #combines dataframes from individual files into one big data table
    ag_missed_blocks<-rbind(ag_missed_blocks,missed_blocks)

}
#missed_blocks<-fromJSON(mb_filenames)
missed_blocks<-ag_missed_blocks
#colnames(missed_blocks)<-c("witness_id","account_id","total_missed","timestamp","block_num")
missed_blocks$timestamp<-gsub(pattern = "T",replacement = " ",x = missed_blocks$timestamp)
missed_blocks$timestamp<-as.POSIXct(missed_blocks$timestamp,tz = "GMT")
missed_blocks$total_missed<-as.numeric(missed_blocks$total_missed)

#save.image("~/Applications/Graphene/Bitshares/graphs/Feed_History/app/appdata.RData")
#save.image("./data/app_files/appdata.RData")
save(witness_list,file = "./data/app_files/witness_list.RData")
save(active_witnesses, file = "./data/app_files/active_witnesses.RData")
save(feed_history , file = "./data/app_files/feed_history.RData")
save(missed_blocks, file = "./data/app_files/missed_blocks.RData")
