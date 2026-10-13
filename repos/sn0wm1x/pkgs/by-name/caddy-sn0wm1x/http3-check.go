package main

import (
	"crypto/tls"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"

	"github.com/sagernet/quic-go/http3"
)

func main() {
	transport := &http3.Transport{TLSClientConfig: &tls.Config{InsecureSkipVerify: true}}
	defer transport.Close()
	client := &http.Client{Transport: transport, Timeout: 10 * time.Second}
	response, err := client.Get(os.Args[1])
	if err != nil {
		panic(err)
	}
	defer response.Body.Close()
	body, err := io.ReadAll(response.Body)
	if err != nil || response.ProtoMajor != 3 || response.StatusCode != 200 || string(body) != "ready" {
		panic(fmt.Sprintf("unexpected HTTP/3 response: %v %s %q", err, response.Status, body))
	}
	fmt.Println("HTTP/3 request succeeded")
}
