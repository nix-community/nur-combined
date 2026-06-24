package main

import (
	"bufio"
	"errors"
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"
	"time"

	"golang.org/x/crypto/ssh"
	"golang.org/x/crypto/ssh/agent"
)

var version = "dev"

type allowKey struct {
	blob    string
	comment string
}

type filterAgent struct {
	upstream        agent.ExtendedAgent
	ordered         []allowKey
	allowed         map[string]struct{}
	auth            authorizer
	hideSessionBind bool
}

func main() {
	var (
		listenPath      = flag.String("listen", "", "proxy ssh-agent socket path")
		upstreamPath    = flag.String("upstream", os.Getenv("BITWARDEN_SSH_AUTH_SOCK"), "upstream ssh-agent socket path")
		keysPath        = flag.String("keys", "", "allowed public keys file, same format as ssh-add -L")
		authEnabled     = flag.Bool("auth", false, "require platform authentication before signing")
		hideSessionBind = flag.Bool(
			"hide-session-bind",
			false,
			"do not forward OpenSSH session-bind extension to upstream agent",
		)
		showVersion = flag.Bool("version", false, "Show version")
	)
	flag.Parse()

	if *showVersion {
		fmt.Println(version)
		return
	}

	if *listenPath == "" {
		log.Fatal("missing -listen")
	}
	if *upstreamPath == "" {
		log.Fatal("missing -upstream or BITWARDEN_SSH_AUTH_SOCK")
	}
	if *keysPath == "" {
		log.Fatal("missing -keys")
	}

	ordered, allowed, err := loadAllowedKeys(*keysPath)
	if err != nil {
		log.Fatal(err)
	}
	if len(ordered) == 0 {
		log.Fatal("no allowed keys loaded")
	}

	if err := os.MkdirAll(filepath.Dir(*listenPath), 0700); err != nil {
		log.Fatal(err)
	}

	_ = os.Remove(*listenPath)

	ln, err := net.Listen("unix", *listenPath)
	if err != nil {
		log.Fatal(err)
	}
	defer ln.Close()

	if err := os.Chmod(*listenPath, 0600); err != nil {
		log.Fatal(err)
	}

	log.Printf("listening:       %s", *listenPath)
	log.Printf("upstream:        %s", *upstreamPath)
	log.Printf("keys:            %s", *keysPath)
	log.Printf("auth:            %t", *authEnabled)
	log.Printf("hideSessionBind: %t", *hideSessionBind)

	auth := authorizer(noopAuthorizer{})
	if *authEnabled {
		auth = newPlatformAuthorizer()
	}

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)

	go func() {
		<-stop
		_ = ln.Close()
		_ = os.Remove(*listenPath)
		os.Exit(0)
	}()

	for {
		c, err := ln.Accept()
		if err != nil {
			if errors.Is(err, net.ErrClosed) {
				return
			}
			log.Printf("accept: %v", err)
			continue
		}

		go func(client net.Conn) {
			defer client.Close()

			up, err := net.Dial("unix", *upstreamPath)
			if err != nil {
				log.Printf("connect upstream: %v", err)
				return
			}
			defer up.Close()

			fa := &filterAgent{
				upstream:        agent.NewClient(up),
				ordered:         ordered,
				allowed:         allowed,
				auth:            auth,
				hideSessionBind: *hideSessionBind,
			}

			if err := agent.ServeAgent(fa, client); err != nil && !errors.Is(err, io.EOF) {
				log.Printf("serve: %v", err)
			}
		}(c)
	}
}

func loadAllowedKeys(path string) ([]allowKey, map[string]struct{}, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, nil, err
	}
	defer f.Close()

	var ordered []allowKey
	allowed := make(map[string]struct{})

	sc := bufio.NewScanner(f)
	lineNo := 0

	for sc.Scan() {
		lineNo++
		line := strings.TrimSpace(sc.Text())

		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		pub, comment, _, _, err := ssh.ParseAuthorizedKey([]byte(line))
		if err != nil {
			return nil, nil, fmt.Errorf("%s:%d: %w", path, lineNo, err)
		}

		blob := string(pub.Marshal())

		ordered = append(ordered, allowKey{
			blob:    blob,
			comment: comment,
		})
		allowed[blob] = struct{}{}
	}

	if err := sc.Err(); err != nil {
		return nil, nil, err
	}

	return ordered, allowed, nil
}

func (a *filterAgent) List() ([]*agent.Key, error) {
	keys, err := a.upstream.List()
	if err != nil {
		return nil, err
	}

	byBlob := make(map[string]*agent.Key, len(keys))
	for _, k := range keys {
		byBlob[string(k.Marshal())] = k
	}

	out := make([]*agent.Key, 0, len(a.ordered))

	for _, wanted := range a.ordered {
		k, ok := byBlob[wanted.blob]
		if !ok {
			continue
		}

		comment := wanted.comment
		if comment == "" {
			comment = k.Comment
		}

		out = append(out, &agent.Key{
			Format:  k.Format,
			Blob:    k.Blob,
			Comment: comment,
		})
	}

	return out, nil
}

func (a *filterAgent) Sign(key ssh.PublicKey, data []byte) (*ssh.Signature, error) {
	if !a.isAllowed(key) {
		return nil, errors.New("key not allowed")
	}
	started := time.Now()
	if err := a.auth.Authorize(key, a.commentFor(key), 0); err != nil {
		return nil, err
	}
	log.Printf("authorize finished after %s: %s", time.Since(started).Round(time.Millisecond), ssh.FingerprintSHA256(key))

	started = time.Now()
	sig, err := a.upstream.Sign(key, data)
	log.Printf("upstream sign finished after %s: %s", time.Since(started).Round(time.Millisecond), ssh.FingerprintSHA256(key))
	return sig, err
}

func (a *filterAgent) SignWithFlags(key ssh.PublicKey, data []byte, flags agent.SignatureFlags) (*ssh.Signature, error) {
	if !a.isAllowed(key) {
		return nil, errors.New("key not allowed")
	}
	started := time.Now()
	if err := a.auth.Authorize(key, a.commentFor(key), flags); err != nil {
		return nil, err
	}
	log.Printf("authorize finished after %s flags=%d: %s", time.Since(started).Round(time.Millisecond), flags, ssh.FingerprintSHA256(key))

	started = time.Now()
	sig, err := a.upstream.SignWithFlags(key, data, flags)
	log.Printf("upstream sign finished after %s flags=%d: %s", time.Since(started).Round(time.Millisecond), flags, ssh.FingerprintSHA256(key))
	return sig, err
}

func (a *filterAgent) isAllowed(key ssh.PublicKey) bool {
	_, ok := a.allowed[string(key.Marshal())]
	return ok
}

func (a *filterAgent) commentFor(key ssh.PublicKey) string {
	blob := string(key.Marshal())
	for _, k := range a.ordered {
		if k.blob == blob {
			return k.comment
		}
	}
	return ssh.FingerprintSHA256(key)
}

func (a *filterAgent) Add(key agent.AddedKey) error {
	return a.upstream.Add(key)
}

func (a *filterAgent) Remove(key ssh.PublicKey) error {
	return a.upstream.Remove(key)
}

func (a *filterAgent) RemoveAll() error {
	return a.upstream.RemoveAll()
}

func (a *filterAgent) Lock(passphrase []byte) error {
	return a.upstream.Lock(passphrase)
}

func (a *filterAgent) Unlock(passphrase []byte) error {
	return a.upstream.Unlock(passphrase)
}

func (a *filterAgent) Signers() ([]ssh.Signer, error) {
	return a.upstream.Signers()
}

const (
	sshAgentSuccess       = 6
	opensshSessionBindExt = "session-bind@openssh.com"
)

func (a *filterAgent) Extension(extensionType string, contents []byte) ([]byte, error) {
	if a.hideSessionBind && extensionType == opensshSessionBindExt {
		log.Printf("dropped extension: %s", extensionType)
		return []byte{sshAgentSuccess}, nil
	}

	return a.upstream.Extension(extensionType, contents)
}
