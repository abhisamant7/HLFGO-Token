# Private data
https://hyperledger-fabric.readthedocs.io/en/release-1.3/private_data_tutorial.html


Install & Instantiate
=====================
dev-init.sh -e

. set-env.sh dfarmadmin

reset-chain-env.sh
set-chain-env.sh  -n priv -v 1.0 -p token/priv -c '{"Args": ["init"]}' -C dfarmchannel
set-chain-env.sh -R pcollection.json

Exercise
=========
Install & Instantiate the token/priv chaincode using "peer chaincode instantiate .." command

<Solution>
Setup the environment variables
chain.sh install
. cc.env.sh
peer chaincode instantiate -C "$CC_CHANNEL_ID" -n "$CC_NAME"  -v "$CC_VERSION" -c "$CC_CONSTRUCTOR" -o "$ORDERER_ADDRESS"  --collections-config "$GOPATH/src/token/priv/pcollection.json"


Test the setup
==============
1. Start the Environment

# Start the environment in net mode
dev-init.sh -e

reset-chain-env.sh

set-chain-env.sh  -n priv -v 1.0 -p token/priv -c '{"Args": ["init"]}' -C dfarmchannel
# Use the -R option to set the PDC
# At instantiation chain.sh will specify the full path to PDC collection
set-chain-env.sh -R pcollection.0.json

Install & Instantiate
. set-env.sh dfarmadmin
chain.sh install
chain.sh instantiate

. set-env.sh dfarmretail
chain.sh install

2. Invoke the Set as DFARMADMIN & Query

<Terminal#1>

# Invoke to set the value for 2 tokens
. set-env.sh dfarmadmin
set-chain-env.sh -i '{"Args": ["Set","DfarmadminDfarmretailOpen", "Dfarmadmin has set the OPEN data"]}'
chain.sh invoke
set-chain-env.sh -i '{"Args": ["Set","DfarmadminPrivate", "Dfarmadmin has set the SECRET data"]}'
chain.sh invoke
# Get the value for 2 tokens
set-chain-env.sh -q '{"Args": ["Get"]}'
chain.sh query

3. Invoke the Set as DFARMRETAIL & Query

<Terminal#2>
. set-env.sh dfarmretail

set-chain-env.sh -i '{"Args": ["Set","DfarmadminDfarmretailOpen", "Dfarmretail has set the OPEN data"]}'
chain.sh invoke

set-chain-env.sh -i '{"Args": ["Set","DfarmadminPrivate", "Dfarmretail has set the SECRET data"]}'
chain.sh invoke

# Get the value for 2 tokens - Dfarmretail will NOT seet the value for protected token
chain.sh query         

4. Query as DFARMADMIN
<Terminal#1>
. set-env.sh dfarmadmin
chain.sh query  

. set-env.sh dfarmadmin

Exercise
========
Extend the priv chaincode - add a function to delete the key in specific collection

. set-env.sh dfarmadmin
set-chain-env.sh -i '{"Args": ["Set","DfarmadminDfarmretailOpen", "Dfarmadmin has set the OPEN data"]}'
chain.sh invoke
set-chain-env.sh -i '{"Args": ["Set","DfarmadminPrivate", "Dfarmadmin has set the SECRET data"]}'
chain.sh invoke


chain.sh query
set-chain-env.sh -i '{"Args": ["Del", "DfarmadminDfarmretailOpen"]}'
chain.sh invoke

chain.sh query


Experimental
============
set-chain-env.sh -i '{"Args": ["Del", "MemberOnlyTest"]}'

Testing in Dev Mode
====================
Use the instructions below to test the PDC in in DEV mode

Install & Instantiate
======================
Regular install process
Instantiate requires the collection.json to be specified
--collections-config

# Start the environment in Dev mode
dev-init.sh dev
set-chain-env.sh  -n priv -v 1.0 -p token/priv -c '{"Args": ["init"]}' 
# Use the -R option to set the PDC
# At instantiation chain.sh will specify the full path to PDC collection
set-chain-env.sh -R pcollection.json

# Launch the chaincode instance on Dfarmadmin Peer
<Terminal#1>
. set-env.sh dfarmadmin
cc-run.sh

# Launch the chaincode instance on Dfarmretail Peer
<Terminal#1>
. set-env.sh dfarmretail
cc-run.sh

<Terminal#3>
# Install the chaincode on Dfarmadmin & Dfarmretail peers
. set-env.sh dfarmadmin
chain.sh install

chain.sh instantiate-priv

. set-env.sh dfarmretail
chain.sh install

Test
====
Invalid collection name will lead to error


1. Dfarmadmin can set both the public & private data
. set-env.sh dfarmadmin
set-chain-env.sh -i '{"Args": ["Set","DfarmadminDfarmretailOpen", "Dfarmadmin has set the OPEN data"]}'
chain.sh invoke
set-chain-env.sh -i '{"Args": ["Set","DfarmadminPrivate", "Dfarmadmin has set the SECRET data"]}'
chain.sh invoke

2. Dfarmadmin can get both public and secret data
set-chain-env.sh -q '{"Args": ["Get"]}'
chain.sh query

3. Dfarmretail can the public & the private data
# Switch context to dfarmretail
. set-env.sh dfarmretail

# Change the parameters for invoke
set-chain-env.sh -i '{"Args": ["Set","DfarmadminDfarmretailOpen", "Dfarmretail has set the OPEN data"]}'
chain.sh invoke

set-chain-env.sh -i '{"Args": ["Set","DfarmadminPrivate", "Dfarmretail has set the SECRET data"]}'
chain.sh invoke

4. Dfarmretail can get only the public data
chain.sh query
