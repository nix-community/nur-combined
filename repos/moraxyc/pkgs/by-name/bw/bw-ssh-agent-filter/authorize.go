package main

import (
	"golang.org/x/crypto/ssh"
	"golang.org/x/crypto/ssh/agent"
)

type authorizer interface {
	Authorize(key ssh.PublicKey, comment string, flags agent.SignatureFlags) error
}

type noopAuthorizer struct{}

func (noopAuthorizer) Authorize(key ssh.PublicKey, comment string, flags agent.SignatureFlags) error {
	return nil
}
