#!/bin/bash
set pairs = "BTC";
echo $pairs;
# curl --silent https://yobit.net/en/market/ | awk --field-separator=">|<"  '$5~/\/BTC/ { print $5 }'
