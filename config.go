package main

import "fmt"

// Docker comtainer
var pullfoundrycmd = "sudo docker pull ghcr.io/foundry-rs/foundry:latest"
var tagfoundrycmd = "sudo docker tag ghcr.io/foundry-rs/foundry:latest foundry:latest"
var allimagescmd = "sudo docker images"
var pullabigencmd = "sudo docker pull ethereum/client-go:alltools-latest"

// Fodundry
var fodundrycmd = "sudo docker run --rm -v $PWD:/app foundry"

// Contract
var contractName = "SBT"
var methodscmd = fmt.Sprintf("forge inspect --root /app %s methods", contractName)
var abicmd = fmt.Sprintf("forge inspect --root /app %s abi", contractName)
var bytescodecmd = fmt.Sprintf("forge inspect --root /app %s bytecode", contractName)
var deploybytescodecmd = fmt.Sprintf("forge inspect --root /app %s deployedBytecode", contractName)
