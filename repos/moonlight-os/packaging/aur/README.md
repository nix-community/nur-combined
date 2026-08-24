# AUR packages

Release CI renders and publishes three package bases:

- `helios`: builds the tagged source release.
- `helios-bin`: installs the x86-64 Arch package attached to the release.
- `helios-git`: builds the current `main` branch and derives its version from Git.

All variants provide `helios` and conflict with the other variants, so switching
uses the standard pacman replacement flow. MsQuic is an explicit dependency;
Moonlight OS transport support is never silently omitted.
