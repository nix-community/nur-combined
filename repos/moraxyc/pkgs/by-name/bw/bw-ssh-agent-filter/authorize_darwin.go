//go:build darwin

package main

import (
	"context"
	"errors"
	"fmt"
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

	if err := touchid.CanAuthenticate(a.policy); err != nil {
		return fmt.Errorf("local authentication unavailable: %w", err)
	}
	if err := touchid.Authenticate(ctx, a.policy, reason); err != nil {
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

	return nil
}
