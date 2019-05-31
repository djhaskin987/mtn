#!/bin/sh
export POSIXLY_CORRECT=1
set -exu

antlr4 -Werror -Xlog -o parser -package parser -Dlanguage=Go -visitor -encoding utf-8 -long-messages MTN.g4
go build .
