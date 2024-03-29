#!/bin/bash

echo    "Installing the chaincode ERC20"
.    set-env.sh    dfarmadmin
set-chain-env.sh       -n erc20  -v 1.0   -p  token/ERC20   
chain.sh install

echo    "Instantiating..."
set-chain-env.sh        -c   '{"Args":["init","ACFT","1000", "A Cloud Fan Token!!!","john"]}'
chain.sh  instantiate

echo "Done."