package main

import (
	"testing"

	"example.com/dep"
)

func TestGreeting(t *testing.T) {
	if dep.Greeting() != "hello from dep" {
		t.Fatal("unexpected greeting")
	}
}
