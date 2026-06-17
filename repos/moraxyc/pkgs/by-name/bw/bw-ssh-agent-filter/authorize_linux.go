//go:build linux

package main

import (
	"context"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"time"

	"golang.org/x/crypto/ssh"
	"golang.org/x/crypto/ssh/agent"
)

var pkcheckPath = "pkcheck"

type polkitAuthorizer struct {
	timeout  time.Duration
	actionID string
}

func newPlatformAuthorizer() authorizer {
	return &polkitAuthorizer{
		timeout:  30 * time.Second,
		actionID: "com.moraxyc.bw-ssh-agent-filter.authorize-sign",
	}
}

func (a *polkitAuthorizer) Authorize(key ssh.PublicKey, comment string, flags agent.SignatureFlags) error {
	ctx, cancel := context.WithTimeout(context.Background(), a.timeout)
	defer cancel()

	cmd := exec.CommandContext(ctx,
		pkcheckPath,
		"--action-id", a.actionID,
		"--process", fmt.Sprint(os.Getpid()),
		"--allow-user-interaction",
	)
	if err := cmd.Run(); err != nil {
		if errors.Is(ctx.Err(), context.DeadlineExceeded) {
			return errors.New("polkit authentication timed out")
		}
		return fmt.Errorf("polkit authentication denied: %w", err)
	}

	return nil
}
