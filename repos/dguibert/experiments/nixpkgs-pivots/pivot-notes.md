https://gist.github.com/Infinisil/3366e7dfc9a01f6eeb25b5cb475cc585

# Nixpkgs Pivots

We have a number of problems that currently require full rebuilds of nixpkgs:

- glibc needs to find third-party nss modules
- cacerts needs to contain custom CA's from enterprises
- tzdata just changed frequently
- locales

Interestingly, Nix's deep pinning of cacerts and tzdata gets in the way of
Nix's promise of packages working over the long term in an archival sense:
invalid tzdata and expired certificates breaks practical usability of this
software.

# Solutions

## Nixpkgs Pivot

solves:

- NIX_SSL_CERT_FILE
- security wrappers (needs setuid, can have pivot dir point to /usr/sbin/sudo on non-NixOS systems)
- opengl, GPU-dependent drivers
-

maybe not:

- zfs commands need to match the booted system, /run/booted-system

Quick notes: Do it all in Nix with exportReferencesClosure and derivation's passthru saying whether they're pivots or pivotable

--

We propose introducing a standardized environment variable named `$NIXPKGS_PIVOT_DIRS`: a colon-separate list of search directories.

We would patch nixpkgs derivations to look in each entry of `$NIXPKGS_PIVOT_DIRS` for a directory named `<hash>` at runtime to discover additional dependencies. `<hash>` is the path suffix of `$out` of the derivations themselves.

A location in `$NIXPKGS_PIVOT_DIRS` could also include symlinks to other directories. If a matching name is found, the search ends.

We can use this to influence runtime impurely if desired.

### Example

- `NIXPKGS_PIVOT_DIRS=/nix/var/nix/profiles/per-user/grahamc/pivot:/nix/var/nix/profiles/per-user/root/pivot`
- We're running a program which uses `/nix/store/kah5n342wz4i0s9lz9ka4bgz91xa2i94-glibc-2.32`
- glibc would look in `/nix/var/nix/profiles/per-user/grahamc/pivot/kah5n342wz4i0s9lz9ka4bgz91xa2i94-glibc-2.32` to discover additional nss libraries.
- If that directory does not exist, glibc would look in `/nix/var/nix/profiles/per-user/root/pivot/kah5n342wz4i0s9lz9ka4bgz91xa2i94-glibc-2.32`.

Software must behave normally if no pivot directory is found.

### Discussion

- Maybe the software should look in every pivot dir, whether or not it finds a match. If it should, it makes it more difficult to completely "shadow" a parent pivot dir, although maybe this is fine by simply reset the `NIXPKGS_PIVOT_DIRS` value.
- If merging behavior of multiple pivot directories is needed, the user can merge the needed directories into a new path and set that as `NIXPKGS_PIVOT_DIRS`
- Maybe it doesn't need to be a search path of multiple entries, because above-described merging could always be done instead. However we probably still want a root/system default.
- `s/_DIRS/_PATH/`? known behavior of XDG vs. PATH: we are looking for a specific thing in each entry, so maybe PATH is more like it.

### Tooling

These pivot directories would be hard to create manually, since they require Nix store hashes that match the dependencies to influence, so we need some tool to create them.

### Scope

The intended use case is for derivations which are _very_ low level in the build tree, where user-specific policy is common but building run-time wrappers becomes infeasible. Concretely, packages at the level of curl and glibc but not so much OBS Studio.

### Limitations

- This does not address build-time issues of enterprise certificate authorities, since NIXPKGS_PIVOT only applies at runtime.

### For build-time, impureEnvVars

Nix allows the propagation of impure environment variables into the build. This is frequently used to allow fetchers to authenticate to restricted URLs.

In particular, `fetchurl` listens to `NIX_CURL_FLAGS`, which can be used to pass the `--cacert <file>` flag, allowing the use of custom CA certs during a build.

## Alternatives

### pkgs.replaceDependency

Nixpkgs has the [pkgs.replaceDependency](https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/replace-dependency.nix) function, which allows one to replace a runtime dependency of a derivation and its closure with another dependency of the same type.

While this might work well, the implementation is rather hacky by relying on IFD, sed and `builtins.unsafeDiscardStringContext`. This might stop working in future Nix versions, perhaps especially with the advent of content-addressed derivations. So this solution should ideally only be used for temporary emergencies.

### Custom Patching

To address just the issue of NSS modules, users could patch glibc.

For example, they might add this patch to their glibc derivation to get a mutable profile for their ld.cache.so. The down-side to this, of course, is the user has diverged from upstream and has no cache coverage. They'll now, essentially, have to run a private hydra to keep up.

```diff
--- a/pkgs/development/libraries/glibc/default.nix
+++ b/pkgs/development/libraries/glibc/default.nix
@@ -88,6 +88,14 @@ callPackage ./common.nix { inherit stdenv; } {
       test -f $out/etc/ld.so.cache && rm $out/etc/ld.so.cache
+      # create symlink to system-wide ld.so.cache that can be managed
+      # with ldconfig(8).
+      ln -s /nix/var/nix/profiles/per-user/root/ldconfig/etc/ld.so.cache $out/etc/ld.so.cache
+
       if test -n "$linuxHeaders"; then
           # Include the Linux kernel headers in Glibc, except the `scsi'
           # subdirectory, which Glibc provides itself.
```

---

---

---

# (Notes from Samuel)

## Using XDG

Either:

- Directly with `XDG_CONFIG_DIRS` only
- With a level of indirection with `XDG_CONFIG_DIRS`

### Directly with `XDG_CONFIG_DIRS` only

1.  With `XDG_CONFIG_DIRS=/etc/xdg:/nix/var/nix/profiles/per-user/username/xdg-for-pivots`
1.  Given the output path `/nix/store/kah5n342wz4i0s9lz9ka4bgz91xa2i94-glibc-2.32`

It would look into the following directories:

- `/etc/xdg/nix/pivots/kah5n342wz4i0s9lz9ka4bgz91xa2i94-glibc-2.32`
- `/nix/var/nix/profiles/per-user/username/xdg-for-pivots/kah5n342wz4i0s9lz9ka4bgz91xa2i94-glibc-2.32`

> Whether a derivation falls through the next pivot when the directory is found or not is out of scope of this.

> What's up with `xdg-for-pivots`? Nothing much, is really a directory that works like `/etc/xdg`, but here we're assuming it's used by a tool that manages it, thus a specific name in case the end-user also has another tool managing `/nix/var/nix/profiles/per-user/username/xdg`. It's not part of the spec, but really an example.

### With a level of indirection with `XDG_CONFIG_DIRS`

1.  With `XDG_CONFIG_DIRS=/etc/xdg:/opt/etc/xdg`
1.  Given the output path `/nix/store/kah5n342wz4i0s9lz9ka4bgz91xa2i94-glibc-2.32`

First, it would look for candidate pivot paths in:

- `/etc/xdg/nix/pivots.conf`
- `/opt/etc/xdg/nix/pivots.conf`

The format here is not specified, but let's assume a list of paths separated by newlines:

```
/nix/var/nix/profiles/per-user/grahamc/pivot
/nix/var/nix/profiles/per-user/root/pivot
```

The collection of paths would then be used as described earlier:

> - We're running a program which uses `/nix/store/kah5n342wz4i0s9lz9ka4bgz91xa2i94-glibc-2.32`
> - glibc would look in `/nix/var/nix/profiles/per-user/grahamc/pivot/kah5n342wz4i0s9lz9ka4bgz91xa2i94-glibc-2.32` to discover additional nss libraries.
> - If that directory does not exist, glibc would look in `/nix/var/nix/profiles/per-user/root/pivot/kah5n342wz4i0s9lz9ka4bgz91xa2i94-glibc-2.32`.

The difference here is that level of indirection works more like the environment-variables backed proposal, and maybe more importantly, does not assume use of XDG dirs directly for the pivot feature, only for its configuration.

I think it is more appropriate, as the pivots themselves are not configuration, so the level of indirection is probably desirable.
