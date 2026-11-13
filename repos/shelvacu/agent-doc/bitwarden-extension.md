# Bitwarden Firefox extension

`nix build .#bitwarden-extension` builds the Firefox extension from Bitwarden's
`browser-v2026.10.2` release commit, `a540dcdb74db44fd90d20d721ef91a7225d5a34f`.
The package uses the source lockfile, a fixed-output npm dependency cache, and
upstream's `build:prod:firefox` script. It excludes the commercial source tree.
The XPI is assembled from the resulting `apps/browser/build` directory.
Nix supplies Dart Sass instead of the npm package's bundled executable.

`opid-cache.patch` applies https://github.com/bitwarden/clients/pull/23784 to the
TypeScript source and includes its insertion/removal regression tests. The build
runs the autofill field collection test suite.

CookieYes inserts hidden preference checkboxes even when consent is already
saved. Inserting them before a scanned login form renumbers its opids. The old
opid lookup then causes the login fields to be removed from Bitwarden's cache.
The patch updates both indexes when a cached field's opid changes. It also
handles fields removed before an existing field.

The local version is 2026.10.2.1 so it replaces an installed 2026.10.2. The source
build is unsigned. Firefox must support disabling signature enforcement and set
`xpinstall.signatures.required` to false to install it persistently. Bitwarden
keeps its original extension ID and vault storage.

This fixes field collection, not sites marking login passwords as
`autocomplete="new-password"`; that still causes password-generation suggestions.

`common/browser/bitwarden.nix` builds Firefox with signature enforcement disabled
and force-installs the local XPI through ExtensionSettings on GUI NixOS hosts,
including `fw` and `compute-deck`. It handles both the stable `requireSigning`
and unstable `enableAddonSigning` build arguments.
Only Bitwarden's automatic updates are disabled; other extension policies remain
in place. This requires a Firefox rebuild. Nothing is deployed by this change.

Validation: the Nix source build passes all 241 field-collection tests, including
both added regression cases. Its XPI fills both live VoIP.ms fields in headless
Firefox 159.0 with CookieYes delayed four seconds and consent already saved.
Inserting and removing additional checkbox inputs preserves both login opid
lookups. Both `fw` and `compute-deck` Firefox policies evaluate to the source-built
XPI.
