//go:build darwin

package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"time"

	touchid "github.com/noamcohen97/touchid-go"
	"golang.org/x/crypto/ssh"
	"golang.org/x/crypto/ssh/agent"
)

type touchIDAuthorizer struct {
	timeout time.Duration
	policy  touchid.Policy
}

func newPlatformAuthorizer() authorizer {
	return &touchIDAuthorizer{
		timeout: 30 * time.Second,
		policy:  touchid.PolicyDeviceOwnerAuthentication,
	}
}

func (a *touchIDAuthorizer) Authorize(key ssh.PublicKey, comment string, flags agent.SignatureFlags) error {
	ctx, cancel := context.WithTimeout(context.Background(), a.timeout)
	defer cancel()

	reason := fmt.Sprintf("Allow SSH signature using %s\n%s", comment, ssh.FingerprintSHA256(key))

	started := time.Now()
	if err := touchid.Authenticate(ctx, a.policy, reason); err != nil {
		log.Printf("auth failed after %s: %s", time.Since(started).Round(time.Millisecond), ssh.FingerprintSHA256(key))
		if errors.Is(err, context.DeadlineExceeded) {
			return errors.New("local authentication timed out")
		}
		if errors.Is(err, touchid.ErrUserCancel) {
			return errors.New("local authentication cancelled")
		}
		if errors.Is(err, touchid.ErrAuthenticationFailed) {
			return errors.New("local authentication failed")
		}
		return fmt.Errorf("local authentication denied: %w", err)
	}
	log.Printf("auth ok after %s: %s", time.Since(started).Round(time.Millisecond), ssh.FingerprintSHA256(key))

	return nil
}
