package main

import (
	"fmt"

	"example.com/dep"
	"github.com/google/uuid"
)

func main() {
	if uuid.NewSHA1(uuid.NameSpaceDNS, []byte("example.com")).Version() != 5 {
		panic("unexpected uuid version")
	}
	fmt.Println(dep.Greeting())
}
