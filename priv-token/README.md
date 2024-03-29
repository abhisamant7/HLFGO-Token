Another example of Private Data Collections
===========================================

priv-token.go
=============
- Manages a single state variable "token" in a PDC with name = "PrivateToken"
- Get function gets the value
- Set function sets the value

Testing
=======
. set-env.sh dfarmadmin
dev-init.sh -e

set-chain-env.sh -n priv-token -v 1.0 -p token/priv-token -c '{"Args":[]}'
set-chain-env.sh -q '{"Args":["Get"]}'
set-chain-env.sh -i '{"Args":["Set","Dfarmadmin Sets the data"]}'

Test#1
======
Use a collection that will allow both Dfarmadmin and Dfarmretail to manage token

set-chain-env.sh -R pcollection.0.json
chain.sh install

chain.sh instantiate

- Set the data with a Dfarmadmin context
. set-env.sh dfarmadmin
chain.sh invoke

- Read the data with Dfarmretail Context
. set-env.sh dfarmretail
chain.sh install
chain.sh query

- The other way will also work

Test#2
======
Now update the PDC collection definition by upgrading the chaincode

. set-env.sh dfarmadmin
set-chain-env.sh -n priv-token -v 2.0 -p token/priv-token
set-chain-env.sh -R pcollection.1.json
chain.sh install
chain.sh upgrade

- Set the data with a Dfarmadmin context
. set-env.sh dfarmadmin
  set-chain-env.sh -i '{"Args":["Set","Dfarmadmin Sets the data with new PDC Definition"]}'
  chain.sh invoke 

  chain.sh query

- Read the data with Dfarmretail Context
. set-env.sh dfarmretail
chain.sh install
chain.sh query

This should fail as only Dfarmadmin is allowed to access the data