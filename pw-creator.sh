#!/bin/sh
cat /dev/urandom | tr -d -c '[:graph:]' | fold -w"${1-32}" | head -n10
