#!/bin/bash

# Unit Testing for v5/token
# Assumes that chaincode is installed & instantiated outside of this script
# Uses the DelState function - so test will fail for the original implementation

# Include the unit test driver
source  utest.sh

# Include the Chaincode environment properties
source cc.env.sh

# Setup the logging level for peer binary
export FABRIC_LOGGING_SPEC='ERROR'

# Set the Organization Context to dfarmadmin
set_org_context  dfarmadmin

############################### Install & Instantiate #############################
# Ignored in 'dev' mode
generate_unique_cc_name

# Set the Organization Context to dfarmadmin
set_org_context  dfarmadmin

# Install
chain_install 

# Instantiate
CC_CONSTRUCTOR='{"Args":[]}'
chain_instantiate
############################### Test Case#1 #######################################
set_test_case   'Chaincode Should return a value > 0'
export CC_QUERY_ARGS='{"Args":["get"]}'
chain_query 
MY_TOKEN_VALUE_1="$QUERY_RESULT" 
print_info  "MY_TOKEN_VALUE_1=$MY_TOKEN_VALUE_1"
# Check if received value is greater than 0
assert_number  $MY_TOKEN_VALUE_1  "-gt"  "0"

############################### Test Case#2 #######################################
set_test_case   'Invoke of set should increase the value of token by 10'
export CC_INVOKE_ARGS='{"Args":["set"]}'
chain_invoke

# Now query again
export CC_QUERY_ARGS='{"Args":["get"]}'
chain_query 
MY_TOKEN_VALUE_2="$QUERY_RESULT" 
print_info  "MY_TOKEN_VALUE_2=$MY_TOKEN_VALUE_2"
# Subtracts first number from second number - value should be 10
assert_number_difference $MY_TOKEN_VALUE_1  $MY_TOKEN_VALUE_2   10

############################### Test Case#3 #######################################
set_test_case   'Token should not be available after it is deleted'
export CC_INVOKE_ARGS='{"Args":["delete"]}'
chain_invoke

# A call to get should return -1
export CC_QUERY_ARGS='{"Args":["get"]}'
chain_query 
MY_TOKEN_VALUE_3="$QUERY_RESULT" 
assert_number  $MY_TOKEN_VALUE_3 "-eq"  "-1"