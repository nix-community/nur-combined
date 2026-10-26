# Architecture diagrams

The [project README](../README.md) embeds the main views and describes the implemented controls and defensive threat model.

| View | Focus | Source |
| --- | --- | --- |
| [Overview](realm-overview.svg) | Requests, private services, and identity control | [D2](realm-overview.d2) |
| [Local transport](local-transport.svg) | Private networks, socket adapters, and peer checks | [D2](local-transport.d2) |
| [Configuration](config-compiler.svg) | Declarations, static catalogs, and system configuration | [D2](config-compiler.d2) |
| [Outbound example](http-egress.svg) | Forgejo Internet, internal HTTPS, and SMTP routes | [D2](http-egress.d2) |
| [Immich routing](immich-routing.svg) | Public and internal entries, share links, and authentication | [D2](immich-routing.d2) |

The diagrams show representative configured paths. They describe neither live traffic nor endpoint health. See the [Realm reference](../docs/realm.md) for module options.

For Immich, `/share` and `/share/*` reach Immich Public Proxy. Other paths reach the main site. Public main-site access adds Caddy Basic Auth. Internal main-site access keeps Immich's own login without that extra gate. Share-link permissions and the proxy's separate Realm identity remain in place.

## Render

Run from the repository root:

```sh
bash layout/render.sh
```

D2 uses its built-in fonts. `D2_BIN` selects another executable. `D2_FONT` selects a custom TTF font. After source changes, render the SVGs and inspect their text, arrows, and boundaries.
