# Architecture diagrams

The [project README](../README.md) embeds the main views and describes the implemented controls and defensive threat model.

| View | Focus | Source |
| --- | --- | --- |
| [Overview](realm-overview.svg) | Node attestation, transparent capture, private services, and SPIFFE identity | [D2](realm-overview.d2) |
| [Transparent agent](transparent-egress.svg) | Root controller, app cgroup BPF, unprivileged worker, DNS and existing SPIFFE egress | [D2](transparent-egress.d2) |
| [Local transport](local-transport.svg) | Private networks, socket adapters, and peer checks | [D2](local-transport.d2) |
| [Configuration](config-compiler.svg) | Declarations, automatic enrollment, static catalogs, and system configuration | [D2](config-compiler.d2) |
| [Outbound example](http-egress.svg) | Forgejo captured TCP/DNS, internal HTTPS, and SMTP routes | [D2](http-egress.d2) |
| [Immich routing](immich-routing.svg) | Public and internal entries, share links, and authentication | [D2](immich-routing.d2) |

The diagrams show representative configured paths. They describe neither live traffic nor endpoint health. See the [Realm reference](../docs/realm.md) for module options.

The transparent path is `app -> app-cgroup BPF -> worker -> declared Unix
egress -> Ghostunnel -> SPIFFE receiver`. The root controller attests local
credentials, unit, cgroup and namespace; it starts one worker per active
workload. Workers share the application's network namespace but stay outside
its captured cgroup. They use distinct unprivileged accounts and have no SPIRE
API access. SPIRE and the existing TLS proxies retain identity and authorization.

Node bootstrap is separate from workload identity. Each Agent proves a
short-lived HTTP FQDN challenge; the Server fetches the proof from the address
pinned in `registry.toml`, without DNS, and the stable alias `agent/<host>`
resolves to the attested `http_fqdn` Agent ID. The HTTP path adds no encryption
or peer authentication, so the registry and the mesh transport are part of the
bootstrap trust boundary. See [HTTP attestation](../docs/realm-http-attestation.md).

Enabled isolated native services and supported rootless containers enroll
automatically. Host-network gateways and external runtimes stay outside
capture. Host and workload opt-outs remain available. Ordinary DNS aliases are
answered locally; external DNS uses DoH through an existing Internet egress.
No such egress means external DNS REFUSED and public TCP denied. Application
DoH/DoT remains encrypted application traffic. Host TUN / sing-box routing can
still apply downstream of the Internet gateway. See the
[agent reference](../pkgs/realm-agent/README.md) and
[deployment record](../docs/realm-agent-rollout.md) for scope and limitations.

For Immich, `/share` and `/share/*` reach Immich Public Proxy. Other paths reach the main site. Public main-site access adds Caddy Basic Auth. Internal main-site access keeps Immich's own login without that extra gate. Share-link permissions and the proxy's separate Realm identity remain in place.

## Render

Run from the repository root:

```sh
bash layout/render.sh
```

D2 uses its built-in fonts. `D2_BIN` selects another executable. `D2_FONT` selects a custom TTF font. After source changes, render the SVGs and inspect their text, arrows, and boundaries.

Each forwarding worker now has a separate resource cgroup and a minimal read-only
mount namespace. Gate attribution pins the socket peer with `SO_PEERPIDFD`.
Recovery failures and worker OOM are handled independently per workload.
