from bitshares import BitShares
from bitshares.block import Block
from bitshares.blockchain import Blockchain
from bitshares.asset import Asset
from bitshares.witness import Witness
from bitsharesapi.bitsharesnoderpc import BitSharesNodeRPC
from pprint import pprint
import time
import json
#witness = Witness()



with open('./data/witness_list/witness_list_raw.txt') as data_file:
    raw_witness_list = json.load(data_file)
pprint(raw_witness_list)
witness_list =[]
for i in raw_witness_list:
    print(i[0])
    account_id = Witness(i[0])
    #i[2]=account_id['witness_account']
    witness_list.append([i[0],i[1],account_id['witness_account']])
    #print(account_id)

B=open('./data/witness_list/witness_list.txt','w')
B.write(json.dumps(witness_list))
B.close()



