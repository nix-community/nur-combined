# NUR Packages

[![build](https://github.com/codgician/nur-packages/actions/workflows/build.yml/badge.svg)](https://github.com/codgician/nur-packages/actions/workflows/build.yml)
[![evergreen](https://github.com/codgician/nur-packages/actions/workflows/evergreen.yml/badge.svg)](https://github.com/codgician/nur-packages/actions/workflows/evergreen.yml)

NUR Packages from codgician.

Packages are built on GitHub Actions via [atelier](https://github.com/stepbrobd/atelier) for `x86_64-linux`, `aarch64-linux` and `aarch64-darwin`.

## Binary cache

- **Cache URL**: `https://cache.codgician.me/nur-packages`
- **Public Key**: `nur-packages:AbWm/DsIy5+TtVaW6GhiZX98nU6y5913NqjEXeeV8mA=`

## NetworkManager GlobalProtect

`networkmanager-gpclient` packages the GlobalProtect SAML NetworkManager service
and GTK/Plasma 6 editors, using nixpkgs' `gpclient` for the tunnel. Add it to
`networking.networkmanager.plugins`, enable `nm-gpclient.service`, and install
`${package}/libexec/gpclient/90-gpclient-routing` as
`/etc/vpnc/connect.d/90-gpclient-routing` to report gateway DNS to NetworkManager.

Set the connection's `vpn.browser` to an absolute browser-wrapper path to reuse
an existing Edge profile instead of upstream's temporary-profile wrapper. Start
the plugin via its independent systemd unit to avoid inheriting NetworkManager's
read-only home namespace. Authentication itself is not patched.
