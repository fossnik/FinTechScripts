#!/bin/bash

# available base pairs - BTC ETH LTC DOGE RUR USD WAVES
BASE="BTC"
base=`echo $BASE | tr [:upper:] [:lower:]`

printf "# Fetching pairs from yobit.net/en/market/ to file 'pairs.btc.list'\n"

# identify and extract pertinent data from html (using awk)
curl --silent https://yobit.net/en/market/ | awk --field-separator='<|>' '$5~/\/'"$BASE"'/ { print tolower($5) }' > pairs.$base.list

# create response.json file with initital JSON bracket
echo '{' > response.json

printf "# Constructing and Executing JSON queries\n"
QUERY="https://yobit.net/api/3/ticker/"
while read pair; do
  # append pair to API query string (use a linking dash)
  QUERY=$QUERY`echo $pair | sed 's/\/'$base'/_'$base'/'`'-'

  # URI query length limit: 530 characters
  if [ `echo $QUERY | wc -m` -lt 530 ]; then
    let $((++TOTALPAIRS))
  else
    printf " Query %s\n" $((++QUERYITERATION))
    # remove the trailing dash
    QUERY=`echo $QUERY | sed s'/-$//'`
    # query API using curl & make the following modifications:
      # insert commas & new line characters for improved readability (using sed)
      # remove inital '{' bracket & suffix with ",\n" for JSON consistancy (sed)
    curl --silent $QUERY | sed -e 's@},"@},\n"@g' -e 's/^.//' -e 's/.$/,\n/' >> response.json
    # prepare for the next group of pairs by resetting query string
    QUERY="https://yobit.net/api/3/ticker/"
  fi
done < pairs.$base.list

# perform final query
curl --silent $QUERY | sed -e 's@},"@},\n"@g' -e 's/^.//' >> response.json

printf "# Process Completed - %s Total Pairs Compiled\n> See file 'response.json' <\n" $TOTALPAIRS
