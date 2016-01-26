#!/bin/bash

# Will launch a quick and dirty Nomad agent in dual client/server mode. This is for
# development purposes only! 
CMD="/usr/local/bin/nomad agent -dev -dc=my-datacenter -region=USA -config=./developer-configuration.hcl"

#echo $CMD
eval $CMD $*
