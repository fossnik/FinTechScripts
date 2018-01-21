#!/bin/bash
BASE="BTC"

# this builds an API query string suitable for yobit.net from a list of tickers
QUERY="https://yobit.net/api/3/ticker/"
while read pair; do
  # URI query length limit: 512 characters
  if [ ${#QUERY} -le 512 ]; then
    # append pair to API query string (bash parameter expansion)
    QUERY=$QUERY`echo $pair | awk '{print tolower($0)}'`"_btc-"
  else
    # query API using curl & make the following modifications:
      # remove trailing dash (via bash parameter substitution)
      # insert commas & new line characters for improved readability (using sed)
      # remove inital '{' bracket & suffix with ",\n" for JSON consistancy (sed)
    # curl --silent ${QUERY%-} | sed -e 's@},"@},\n"@g' -e 's/^.//' -e 's/.$/,\n/' >> response.json
    echo ${QUERY%-}
    # prepare for the next group of pairs by resetting query string
    QUERY="https://yobit.net/api/3/ticker/"
  fi
done < yobit.coins.list
