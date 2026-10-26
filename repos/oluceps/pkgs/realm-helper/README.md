# realm-helper

Small static binary that does the user-space work a realm workload cannot do
without a network route. Standard library only, `CGO_ENABLED=0`, so the same
artifact runs in a hardened systemd sandbox and inside arbitrary container
images.

```text
realm-helper bridge --target ADDRESS      socket-activated listener -> TCP address or Unix socket
realm-helper launch COMMAND [ARG...]      container entrypoint adapter
realm-helper spire-register ...           reconcile SPIRE registrations
realm-helper wait-spire-agent ...         wait for the Agent API
realm-helper enroll NODE                  issue a join token and trust bundle
realm-helper install-enrollment           consume that JSON on the target node
```

## bridge

Replaces a `systemd-socket-proxyd` instance where the target is a
workload-private loopback address (the container SOCKS adapter) — same job, one
fewer binary in the closure.

## launch

`launch` runs inside the container as the entrypoint:

- every entry of `/realm/routes.json` becomes a loopback listener that pipes to
  a mounted egress Unix socket (TCP-only clients never see the socket);
- `REALM_INGRESS_PORT`, when set, publishes `/realm/backend/http.sock` for an
  application that serves TCP but cannot create its own Unix listener;
- the real command runs as a child; the helper forwards termination signals,
  reaps orphans (it may be PID 1) and exits with the child's status.

## spire-register

Runs on the SPIRE server host as a oneshot with `restartTriggers`, so a deployed
configuration re-applies the declaration once instead of polling:

```text
manifest (node -> entry) --create/update--> spire-server
state file (IDs created last time) --prune--> entries removed from the manifest
```

Entry IDs are UUIDv5 of `nyaw-realm:<node>:<name>`, deliberately identical to
the Python implementation this replaced: existing registrations keep their IDs,
so a deployment updates in place instead of creating a second set. Entries that
were never created by this command are never deleted.

## wait-spire-agent

Runs as `spire-agent.service`'s `ExecStartPost`. It reads `MAINPID` from systemd
and waits for the Workload API socket and a successful `spire-agent healthcheck`.
Each check has a five-second timeout. Failed checks retry after three seconds.
If the Agent exits before the API is ready, the command fails.
The unit's `TimeoutStartSec=300s` limits the total wait.

## enroll / install-enrollment

The two halves of node enrollment, joined by a pipe over the existing root SSH
trust boundary:

```sh
ssh root@eihort realm-enroll abhoth | ssh root@abhoth realm-install-enrollment
```

`enroll` validates the node against the manifest keys, asks the server for a
single-use token (`-ttl 600`) and prints `{node, token, bundle}` on stdout only.
`install-enrollment` refuses to run unprivileged or for another hostname, writes
`join-token` and `trust-bundle.pem` into `/var/lib/realm-spire` with
`O_NOFOLLOW`/0600, then restarts `spire-agent`.

## Development

```sh
cd pkgs/realm-helper
go test -race ./...
```

The tests use Unix sockets, temporary files and local listeners to check socket
bridging, registration updates, enrollment and child process exit status.
