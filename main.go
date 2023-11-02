package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
)

func init() {
	out, err := exec.Command("/bin/sh", "-c", allimagescmd).Output()
	if err != nil {
		log.Fatal(err)
	}
	isfoundryExists := strings.Index(string(out), "ghcr.io/foundry-rs/foundry")
	if isfoundryExists == -1 {
		fmt.Println("Pull_Foundry_Container")
		_, err := exec.Command("/bin/sh", "-c", pullfoundrycmd).Output()
		if err != nil {
			log.Fatal(err)
		}
		_, err = exec.Command("/bin/sh", "-c", tagfoundrycmd).Output()
		if err != nil {
			log.Fatal(err)
		}
	}

	isabigenTagExists := strings.Index(string(out), "alltools-latest")
	isabigenExists := strings.Index(string(out), "ethereum/client-go")
	if isabigenTagExists == -1 || isabigenExists == -1 {
		fmt.Println("Pull_ethereum/client-go_AllTolls")
		_, err := exec.Command("/bin/sh", "-c", pullabigencmd).Output()
		if err != nil {
			log.Fatal(err)
		}
	}
}

func generateContractGolang() {
	abicmdArgs := fmt.Sprintf(fodundrycmd+" \"%s\"", abicmd)
	fmt.Println(abicmdArgs)
	abicmdout, err := exec.Command("/bin/sh", "-c", abicmdArgs).Output()
	if err != nil {
		log.Fatal(err)
	}

	bytescodecmdArgs := fmt.Sprintf(fodundrycmd+" \"%s\"", bytescodecmd)
	fmt.Println(bytescodecmdArgs)
	bytescodecmdout, err := exec.Command("/bin/sh", "-c", bytescodecmdArgs).Output()
	if err != nil {
		log.Fatal(err)
	}

	abiFile, err := os.Create("sc.abi")
	if err != nil {
		panic(err)
	}
	defer os.Remove(abiFile.Name())
	_, err = abiFile.Write(abicmdout)
	if err != nil {
		panic(err)
	}
	//fmt.Println("filePath:", abiFile.Name())
	bytecodeFile, err := os.Create("sc.bin")
	if err != nil {
		panic(err)
	}
	defer os.Remove(bytecodeFile.Name())
	_, err = bytecodeFile.Write(bytescodecmdout)
	if err != nil {
		panic(err)
	}
	//fmt.Println("filePath:", bytecodeFile.Name())
	pack := strings.ToLower(contractName)
	abigencmd := fmt.Sprintf("sudo docker run --rm -v $PWD:/app ethereum/client-go:alltools-latest abigen --bin /app/sc.bin --abi /app/sc.abi --pkg %s --out /app/%s.go", pack, pack)
	_, err = exec.Command("/bin/sh", "-c", abigencmd).Output()
	if err != nil {
		log.Fatal(err)
	}
}

func generateContractMethos() {
	methodscmdArgs := fmt.Sprintf(fodundrycmd+" \"%s\"", methodscmd)
	fmt.Println(methodscmdArgs)
	methodsout, err := exec.Command("/bin/sh", "-c", methodscmdArgs).Output()
	if err != nil {
		log.Fatal(err)
	}
	//methodsArray := strings.Split(strings.Trim(string(methodsout), "{}"), ",")
	//fmt.Println(methodsArray[0])
	bytecodeFile, err := os.Create("scmethod.txt")
	if err != nil {
		panic(err)
	}
	//defer os.Remove(bytecodeFile.Name())
	_, err = bytecodeFile.Write(methodsout)
	if err != nil {
		panic(err)
	}
}

func main() {
	//generateContractGolang()
	generateContractMethos()
}
