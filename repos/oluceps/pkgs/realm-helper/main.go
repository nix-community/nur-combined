// Command realm-helper is the user-space half of the realm workload isolation
// stack.
//
// A realm workload has no network route: everything it needs outside its
// namespace crosses the boundary as a Unix socket. A few small jobs must still
// run inside that namespace, and this one binary covers all of them:
//
//	realm-helper bridge --target ADDRESS     splice a socket-activated listener
//	realm-helper launch COMMAND [ARG...]     container entrypoint adapter
//	realm-helper spire-register ...          apply the declared SPIRE entries
//	realm-helper wait-spire-agent ...        wait for the Agent API
//	realm-helper enroll NODE                 issue a join token and trust bundle
//	realm-helper install-enrollment         consume that JSON on the target node
//
// It is a static binary with no dependencies outside the Go standard library,
// so the same artifact runs inside a hardened systemd sandbox and inside
// arbitrary container images that have no Go runtime or Node interpreter.
package main

import (
	"fmt"
	"os"
)

const usage = `usage:
  realm-helper bridge --target ADDRESS
  realm-helper launch COMMAND [ARG...]
  realm-helper spire-register --spire-server PATH --socket PATH --manifest PATH --state PATH
  realm-helper wait-spire-agent --spire-agent PATH --socket PATH
  realm-helper enroll NODE --spire-server PATH --socket PATH --manifest PATH --trust-domain DOMAIN
  realm-helper install-enrollment --node HOSTNAME --systemctl PATH < enrollment.json
`

func main() {
	if len(os.Args) < 2 {
		fmt.Fprint(os.Stderr, usage)
		os.Exit(2)
	}

	code, err := run(os.Args[1:])
	if err != nil {
		fmt.Fprintf(os.Stderr, "realm-helper %s: %v\n", os.Args[1], err)
		if code == 0 {
			code = 1
		}
	}
	os.Exit(code)
}

// run dispatches one subcommand and reports the exit code a container should
// see. Errors are returned separately so a child's exit status is never
// confused with a helper failure.
func run(args []string) (int, error) {
	switch args[0] {
	case "bridge":
		return 0, bridgeCommand(args[1:])
	case "launch":
		return launchCommand(args[1:])
	case "spire-register":
		return 0, spireRegisterCommand(args[1:])
	case "wait-spire-agent":
		return 0, waitSpireAgentCommand(args[1:])
	case "enroll":
		return 0, enrollCommand(args[1:])
	case "install-enrollment":
		return 0, installEnrollmentCommand(args[1:])
	case "help", "-h", "--help":
		fmt.Print(usage)
		return 0, nil
	default:
		return 2, fmt.Errorf("unknown subcommand %q\n%s", args[0], usage)
	}
}
