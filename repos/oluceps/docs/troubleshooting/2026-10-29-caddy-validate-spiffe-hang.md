# Troubleshooting Guide: `caddy validate` Hangs on the Realm Internet Gateway

## Problem

Running the validation step by hand never returns:

```sh
caddy validate --config /etc/realm-internet/config.json
```

The command prints two lines and then blocks with no further output and no error:

```
{"level":"info","msg":"using config from file","file":"/etc/realm-internet/config.json"}
{"level":"info","logger":"tls.cache.maintenance","msg":"started background certificate maintenance"}
```

Under `timeout` it simply reports the timeout, so it looks like a broken
configuration. The same command returns immediately when the unit runs it, which
makes the hang easy to misread as an intermittent fault.

## Root Cause

`lib/realm/caddy-internet.nix` issues the gateway certificate through the SPIFFE
Workload API. The `tls.get_certificate.spiffe` module obtains its X509 context by
calling `SVIDSource.Provision`, which calls `workloadapi.NewX509Source`. That
constructor blocks until the Workload API delivers the first X509 context, and
it has no timeout of its own.

A Workload API client is only served when both registration selectors match the
calling process:

```
systemd:id:realm-internet.service
unix:user:internet
```

A shell run as `root` matches neither, and even a shell run as the workload user
matches only the second one. The Agent answers `PermissionDenied: no identity
issued`, the watcher backs off and retries forever, and `validate` waits on a
context that will never arrive.

Evidence on a live node:

```sh
spire-agent api fetch -socketPath /run/spire/agent/public/api.sock
# rpc error: code = PermissionDenied desc = no identity issued

journalctl -u spire-agent -o cat | grep 'No identity issued'
# {"level":"error","method":"FetchX509SVID","msg":"No identity issued","registered":false,...}
```

A `SIGQUIT` goroutine dump of the hung process points at the same place:

```
github.com/spiffe/go-spiffe/v2/workloadapi.NewX509Source
github.com/oluceps/caddy-plugins-realm/spiffe.(*SVIDSource).Provision
```

The same behaviour reproduces on a node whose gateway is already running under
Caddy, so it is not specific to one generation or one host.

## Consequence

- Do not use a manual `caddy validate` as a pre-flight check. A hang is expected
  outside the unit and says nothing about the configuration being invalid.
  Running it as the workload user with `setpriv` does not help; the `systemd:id`
  selector still cannot match.
- Inside the unit the same command matches both selectors and returns quickly,
  which is why `ExecStartPre` is safe in normal operation.
- If the Workload API is unavailable when the unit starts, `ExecStartPre` blocks
  instead of failing fast. With the default `TimeoutStartSec` the start hangs
  for roughly 90 seconds, is killed, and `Restart=on-failure` repeats the cycle.
  A restart under those conditions looks like "the gateway will not come up"
  rather than "the Agent cannot issue the SVID"; check `spire-agent` first.

## Verification Instead

Confirm the running gateway, not a dry-run:

```sh
comm=$(cat /proc/"$(systemctl show realm-internet -p MainPID --value)"/comm); echo "$comm"   # caddy
curl -fsS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:19329/metrics                     # 200
ss -ltnH | grep -E ':(19328|19329|19330) '                                                    # all three
```

And from the observability side, after one scrape interval:

```promql
up{job="internet-gateway"} == 1
realm_workload_svid_observation_success{unit="realm-internet.service"} == 1
realm_identity_collector_success{collector="workloads"} == 1
```

`realm-internet` binds the public listener on the node mesh address (`19328`),
the loopback metrics endpoint (`19329`), and the loopback identity probe
(`19330`). The exporter's `caddy_loaded` probe and the `internet-gateway` scrape
both depend on those last two, so a gateway running an older binary shows up as
`InternetGatewayDown` and `RealmIdentityWorkloadFailed` at the same time.
