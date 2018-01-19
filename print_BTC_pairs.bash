#!/bin/bash

curl --silent https://yobit.net/en/market/ | awk --field-separator=">|<"  '$5~/\/BTC/ { print $5 }'
