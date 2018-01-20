#!/bin/bash

# available base pairs - BTC ETH LTC DOGE RUR USD WAVES
BASE="BTC"

printf "# Fetching pairs from yobit.net/en/market/ to file 'pairs.btc.list'\n"
curl --silent https://yobit.net/en/market/ | awk --field-separator='<|>' '$5~/\/'"$BASE"'/ { print tolower($5) }' > pairs.btc.list

QUERY="https://yobit.net/api/3/ticker/"

# Create response file with initital JSON bracket
echo '{' > response.json

printf "# Constructing and Executing JSON queries\n"
while read pair; do
  let $((++TOTALPAIRS))
  # limit length of URI query to 512 characters
  if [ ${#QUERY} -le 512 ]; then
    # Constructing API query string using bash parameter expansion
    QUERY=$QUERY${pair/\/${BASE,,}/_${BASE,,}-}
  else
    printf " Query %s\n" $((++QUERYITERATION))
    # query API with curl
    # remove trailing dash via bash parameter substitution
    # insert newlines using sed for improved readability
    # remove inital '{' bracket, and terminate with ",\n" for JSON consistancy
    curl --silent ${QUERY%-} | sed -e 's@},"@},\n"@g' -e 's/^.//' -e 's/.$/,\n/' >> response.json
    # start afresh with a new query
    QUERY="https://yobit.net/api/3/ticker/"
  fi
done < pairs.btc.list

# perform final query
curl --silent ${QUERY%-} | sed -e 's@},"@},\n"@g' -e 's/^.//' >> response.json

printf "# Process Completed - %s Total Pairs Compiled\n> See file 'response.json' <\n" $TOTALPAIRS
