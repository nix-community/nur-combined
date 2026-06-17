//go:build !darwin && !linux

package main

import (
	"errors"

	"golang.org/x/crypto/ssh"
	"golang.org/x/crypto/ssh/agent"
)

func newPlatformAuthorizer() authorizer {
	return unsupportedAuthorizer{}
}

type unsupportedAuthorizer struct{}

func (unsupportedAuthorizer) Authorize(key ssh.PublicKey, comment string, flags agent.SignatureFlags) error {
	return errors.New("platform authentication is unsupported on this system")
}
