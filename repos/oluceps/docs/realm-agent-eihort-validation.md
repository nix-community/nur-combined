# Realm agent pilot on eihort

Validated on 2026-10-27, Linux 6.18.54, rootless Podman and the existing Misskey
image. No networking changes were made on the developer machine.

## Results

- All nine embedded BPF programs loaded and attached on the target kernel.
- The generated, hardened root systemd unit passed a PrivateNetwork readiness
  probe with a separate application UID and an unprivileged worker UID.
- Two successive rootless container generations passed using Misskey's actual
  CacheableLookup with `lookup: false`, including HTTPS's ADDRCONFIG behavior.
- The fixture fetched an internal S3 avatar and public HTTPS with all proxy
  environment variables removed. Both returned 200.
- IPv4/IPv6 UDP DNS preserved resolver source addresses and peer names; eight
  simultaneous resolver peers worked, and a ninth was rejected. TCP DNS and
  128 concurrent TCP forwarding requests passed, including half-close.
- Undeclared private TCP and unsupported external UDP were denied. Killing the
  worker recovered without another gate. Restarting the agent recovered the
  existing application; while stopped, no direct Internet route was available.

eihort's sing-box TUN supplies host fake-IP answers from `30.40.0.0/16` and
`3072:a866:35c6:b73:26e5:d2e3:3fb2:0/112`. The fixture's application DNS returned
real public A/AAAA records outside those pools. The authenticated Internet
gateway retained its existing host TUN routing; sing-box was not reconfigured.

## Production pilot

The same public Misskey `/proxy/avatar.webp` request for a local S3 object
returned 500 before switching the container and `200 image/webp` afterwards.
A remote avatar returned `200 image/webp` both before and after the switch.
The running container had:

- `s3.nyaw.xyz` resolving to `127.0.0.1` through intercepted DNS;
- real public DNS answers, with no HTTP/HTTPS/ALL proxy environment variables;
- only `lo` and the isolated `realm0` dummy interface;
- healthy Misskey and agent systemd services.

An initial production fault injection exposed that `Requires` propagated the
agent's automatic restart into a Misskey restart. The integration now uses
`Wants` plus the mandatory readiness gate, so the agent can recover independently.
Repeating the production SIGKILL test after that correction left Misskey's
service PID unchanged; both avatar requests still returned `200 image/webp`.
The worker had an unprivileged UID, no supplementary groups, zero effective
capabilities and `NoNewPrivs: 1`.

The pilot uses `/run/systemd/system/realm-agent.service` and
`/run/systemd/system/podman-misskey.service.d/80-realm-agent-pilot.conf`.
It replaces the container start script and adds its agent dependency. Nix
closures are kept under `/nix/var/nix/gcroots/realm-agent-pilot`.

The dedicated `rnet-misskey` account was added through the running host's
userborn declaration with only that account appended. The temporary userborn
override was removed after the account update. Future declarative deployment
creates the account through `nixosModules/realm-agent.nix`.

These runtime units disappear on reboot. Deploy the branch's normal eihort
configuration for persistent activation. To roll back the pilot, remove the
Misskey runtime drop-in, daemon-reload, restart `podman-misskey.service`, then
stop the agent. The original store-backed container unit remains available.

See [the agent README](../pkgs/realm-agent/README.md) for the trust boundary,
configuration, protocol limits and integration test runners.
