#!/bin/bash

printf "Fetching pairs from yobit.net/en/market/ to file 'pairs.btc.list'\n"
curl --silent https://yobit.net/en/market/ | awk --field-separator=">|<"  '$5~/\/BTC/ { print tolower($5) }' > pairs.btc.list

QUERY="https://yobit.net/api/3/ticker/"

# clear the output file
echo "" > response.json

printf "Building and Executing JSON queries\n"
while read pair; do
  # limit URI query to 1024 characters
  if [ ${#QUERY} -le 1024 ]
  then
    # parameter subsistution swaps /btc for _btc-
    QUERY=$QUERY${pair/\/btc/_btc-}
  else
    printf "Query %s\n" $((++QUERYITERATION))
    # query API (removing trailing dash)
    curl --silent ${QUERY%-} >> response.json
    # start afresh for a new query
    QUERY="https://yobit.net/api/3/ticker/"
  fi
done < pairs.btc.list

# perform final query
curl --silent ${QUERY%-} >> response.json

printf "Process Completed !\n> See file 'response.json'\n"
