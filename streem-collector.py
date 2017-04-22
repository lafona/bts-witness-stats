import csv
import time
import datetime
import math
from bitshares import BitShares
from bitshares.block import Block
from bitshares.blockchain import Blockchain
from bitshares.asset import Asset
from bitshares.witness import Witness
from bitsharesapi.bitsharesnoderpc import BitSharesNodeRPC
from pprint import pprint
import json

#bitshares = BitShares(node = 'ws://localhost:8095')
bitshares = BitShares(node = 'wss://bitshares.openledger.info/ws')
#bitshares = BitShares(node = 'ws://51.15.61.160/ws')
chain = Blockchain(bitshares)
usd = Asset("USD")
#print(Block(1,bitshares_instance = bitshares))
pprint(Block(1))
#last_block_time = chain.get_current_block()['timestamp']
#pprint(chain.info())

#chain_info=chain.info()
#pprint(usd)
#rpc =BitSharesNodeRPC("ws://localhost:8095", "", "")
rpc =BitSharesNodeRPC("wss://bitshares.openledger.info/ws", "", "")
feed_data_array = []
missed_block_array =[]
with open('./data/witness_list/witness_list.txt') as data_file:    
    witness_list = json.load(data_file)
print(witness_list)
while True:
    if datetime.datetime.now().minute % 5 ==0:

#        block = rpc.
        #pprint(chain.get_current_block())
        #pprint(chain.get_chain_properties())
        block_num = chain.get_current_block_num()
        print(block_num)

        print(math.floor(int(block_num)/100000))
        if True: #int(block_num) % int(block_num) == 0:
            active_witness_list = rpc.get_object("2.12.0")['current_shuffled_witnesses']
            time.sleep(0.2)
            last_block_time = chain.get_current_block()['timestamp']
            #pprint(chain.get_current_block())
            time.sleep(0.2)
            feed = rpc.get_object("2.4.21")

            #pprint(feed)
            feeds = feed['feeds']
            for i in feeds:
                witness = i[0]
                feeddata = i[1][1]
                feedtime = i[1][0]
                settlement = i[1][1]['settlement_price']
                base_usd =i[1][1]['settlement_price']['base']['amount']
                quote_bts=i[1][1]['settlement_price']['quote']['amount']
                #print(base_usd)
                #print(quote_bts)
                #print(settlement)
                pprint(chain.info())
                feed_data_array.append([last_block_time,witness,feedtime,base_usd,quote_bts,block_num])
            for wit in witness_list:
                block_num = chain.get_current_block_num()
                time.sleep(0.1)
                witness_info = rpc.get_object(wit[1])
                print(witness_info['id'],witness_info['witness_account'],witness_info['total_missed'])
                missed_block_array.append([witness_info['id'],witness_info['witness_account'],witness_info['total_missed'],last_block_time,block_num])
                time.sleep(0.1)                

            A=open('./data/feed_history/feed_history' + str(math.floor(int(block_num)/100000))+'00000.txt','w')
            A.write(json.dumps(feed_data_array))
            A.close()
            
            B=open('./data/witness_list/active_witnesses' + '.txt','w')
#            A=open('./data/active_witnesses_' + str(math.floor(int(block_num)/100000))+'00000.txt','w')
            B.write(json.dumps(active_witness_list))
            B.close()
            
            C=open('./data/missed_blocks/missed_blocks' + str(math.floor(int(block_num)/100000))+'00000.txt','w')
            C.write(json.dumps(missed_block_array))
            C.close()
#            uncomment to write csv
#
#            with open("./data/feed_history.csv", "w", newline="") as f:            
#                writer = csv.writer(f)
#                writer.writerows(feed_data_array)
            
            
            
            print("sleeping")
            #pprint(chain.get_current_block())

        time.sleep(60)

                                                                
