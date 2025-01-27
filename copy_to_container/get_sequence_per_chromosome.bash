#!/bin/bash

# Delete every header that does not contain "NC_" and their corresponding sequence lines to get the primary assembly
awk '/^>/ {
    if (header != "" && matched) {
        print header
        printf "%s", seq
    }
    header = $0
    seq = ""
    matched = /NC_/
    next
}
{
    if (matched) {
        seq = seq $0 "\n"
    }
}
END {
    if (header != "" && matched) {
        print header
        printf "%s", seq
    }
}' $1
