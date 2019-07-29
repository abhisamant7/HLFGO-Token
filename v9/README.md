Dependency management
govendor init
https://github.com/golang/go/wiki/PackageManagementTools

# Get the package for 
go get github.com/hyperledger/fabric/core/chaincode/shim/ext/statebased


Demostrates the use of Endorsement policies
===========================================
1. Setup the env
    . set-env.sh   dfarmadmin
    set-chain-env.sh  -n token -v 1.0 -p token/v9 -c '{"Args": ["init"]}'

2. Install & Instantiate
    chain.sh install
    set-chain-env.sh -P   "OR('DfarmretailMSP.member')"
    chain.sh instantiate

3. Setup the event listener
    events.sh -t chaincode -n token -e SetToken -c dfarmchannel 

4. Query <Teminal#2>
    
    set-chain-env.sh -q   '{"args":["get"]}'
    chain.sh   query     Will work for both Dfarmadmin & Dfarmretail

5. <Terminal#2> Invoke Will work for Dfarmretail only unless Dfarmadmin sends Txn proposal to Dfarmretailx
    . set-env.sh   dfarmadmin
    set-chain-env.sh  -i   '{"args":["set", "UnProtectedToken","By Dfarmadmin"]}' 
    chain.sh invoke

6.  Install on Dfarmretail
    . set-env.sh dfarmretail
    chain.sh install

7.  Invoke on Dfarmadmin again
. set-env.sh  dfarmadmin
   .   cc.env.sh

   peer chaincode invoke -o "$ORDERER_ADDRESS" -C "$CC_CHANNEL_ID" -n "$CC_NAME"  -c "$CC_INVOKE_ARGS" --peerAddresses dfarmretail-peer1.dfarmretail.com:8051

   Execute invoke with Dfarmretail context
   . set-env.sh dfarmretail
   chain.sh install

   set-chain-env.sh -i   '{"args":["set", "UnProtectedToken","Dfarmretail"]}' 
   chain.sh invoke

Exercise Upgrade EP
===================
Launch the environment with explorer
1. Setup the chaincode environment
   set-chain-env.sh -v 2.0   -P   "AND('DfarmadminMSP.member', 'DfarmretailMSP.member')"

2. Upgrade the Chaincode with new policy 
   . set-env.sh dfarmadmin
   chain.sh install
   chain.sh upgrade

 3. Invoke the chain code

   . cc.env.sh

   peer chaincode invoke -o "$ORDERER_ADDRESS" -C "$CC_CHANNEL_ID" -n "$CC_NAME"  -c "$CC_INVOKE_ARGS" --peerAddresses dfarmadmin-peer1.dfarmadmin.com:7051  --peerAddresses dfarmretail-peer1.dfarmretail.com:8051

   Check in the Explorer

4. Kill the container for one of the peers
   docker kill dfarmadmin-peer1.dfarmadmin.com

5. Invoke the chain code
   peer chaincode invoke -o "$ORDERER_ADDRESS" -C "$CC_CHANNEL_ID" -n "$CC_NAME"  -c "$CC_INVOKE_ARGS"   --peerAddresses dfarmretail-peer1.dfarmretail.com:8051

   Check in the explorer


Key Level EP
============
1. Initialize the env
    dev-init.sh  -e

2. Install & Instantiate without chaincode EP
   .  set-env.sh  dfarmadmin
   chain.sh install

   . set-env.sh   dfarmretail
   chain.sh install
   # Ensure chaincode EP is nil
   set-chain-env.sh   -P  ""
   chain.sh instantiate


4. Set the EP for "ProtectedToken"
   .  set-env.sh  dfarmadmin
   set-chain-env.sh -i   '{"args":["setEP", "DfarmretailMSP.member"]}' 
   chain.sh invoke


3. Check the current EP for "ProtectedToken"
   set-chain-env.sh -q   '{"args":["getEP"]}'
   chain.sh query

6. Set the value of the "UnProtectedToken" value as "Dfarmadmin"
   . set-env.sh dfarmadmin
   set-chain-env.sh -i   '{"args":["set", "UnProtectedToken","Dfarmadmin setting it"]}' 
   chain.sh invoke

6. Set the value of the "ProtectedToken" value as "Dfarmadmin"
   . set-env.sh dfarmadmin
   set-chain-env.sh -i   '{"args":["set", "ProtectedToken","Dfarmadmin setting it"]}' 

   # Negative test - this will fail
   chain.sh invoke

   # Positive test - execute against the dfarmretail peer
   . cc.env.sh
   peer chaincode invoke -o "$ORDERER_ADDRESS" -C "$CC_CHANNEL_ID" -n "$CC_NAME"  -c "$CC_INVOKE_ARGS"    --peerAddresses dfarmadmin-peer1.dfarmadmin.com:7051 --peerAddresses dfarmretail-peer1.dfarmretail.com:8051

    Checkout the last 2 transactions

8.  Set the value of the "UnProtectedToken" as "Dfarmadmin"


9.  chain.sh install
10. chain.sh invoke




Testing:

1. Setup the chaincode without EP
> Each org will use their own default peers 
> In dev setup this policy is like "OR('DfarmadminMSP', 'DfarmretailMSP')"

2. Setup the chaincode with EP "OR('DfarmretailMSP.member')"
> This says that DfarmretailMSP peer must endorse the transactions
set-chain-env.sh -P "OR('DfarmretailMSP.member')"

docker kill dfarmretail-peer1.dfarmretail.com
To restart dfarmretail peer =>  dev-start.sh


Endorsement Policy Testing
==========================
1. Start the environment in net mode
> dev-init.sh

2. Set the chaincode environment
> set-chain-env.sh -n token -v 1.0 -p token/v9  -c  '{"args":[]}'

3. Set the endorsement policy for the chaincode
>  set-chain-env.sh -P "OR('DfarmretailMSP.member')"

4. Set the environment context to dfarmadmin
> . set-env.sh dfarmadmin
> chain.sh install
> chain.sh instantiate
# This is equivalent to below:
peer chaincode instantiate -c  '{"args":[]}' -C dfarmchannel -n token -v 1.0 -P "OR('DfarmretailMSP.member')" -o orderer.dfarmadmin.com:7050

5. Now invoke the chaincode
> set-chain-env.sh   -i   '{"args":["set"]}' -q   '{"args":["get"]}'
> chain.sh invoke
> Checkout the explorer - you will see a transaction with "EP Failure"
  # Invoke need to be sent to the EP
> export CORE_PEER_ADDRESS=dfarmretail-peer1.dfarmretail.com:8051
> chain.sh invoke
> Checkout the explorer - you will see a transaction with "EP Failure"

6. Now install the chaincode on dfarmretail
> . set-env.sh dfarmretail
> chain.sh install

7.  Now invoke the chaincode as dfarmadmin
> . set-env.sh dfarmadmin
> export CORE_PEER_ADDRESS=dfarmretail-peer1.dfarmretail.com:8051
> chain.sh invoke
> Checkout the explorer - you will see a VALID transaction


Peer chaincode invoke on multiple Endorsers




. set-env.sh  dfarmretail
chain.sh install

* 5.3 Now invoke the chaincode as dfarmadmin

Check the explorer - you will find a VALID txn from Dfarmadmin

6. Test with EP down
6.1 To kill just use the docker kill
> docker kill dfarmretail-peer1.dfarmretail.com

Exercise
========
set-chain-env.sh -P "AND('DfarmadminMSP.member','DfarmretailMSP.member')"

chain.sh install
chain.sh instantiate
peer invoke --peerAddresses dfarmadmin-peer1.dfarmadmin.com:7051 --peerAddresses dfarmretail-peer1.dfarmretail.com.com:7051

export CORE_PEER_ADDRESS=dfarmretail-peer1.dfarmretail.com:8051,dfarmretail-peer1.dfarmretail.com.com:7051

peer chaincode invoke -o "$ORDERER_ADDRESS" -C "$CC_CHANNEL_ID" -n "$CC_NAME"  -c "$CC_INVOKE_ARGS" --peerAddresses dfarmadmin-peer1.dfarmadmin.com:7051 --peerAddresses dfarmretail-peer1.dfarmretail.com:8051

. set-env.sh dfarmadmin
chain.sh install

6. Test with one of the EP down
6.1 To kill just use the docker kill
> docker kill dfarmretail-peer1.dfarmretail.com