Development Notes
=================

Just some random notes on instantNix development.

Update
------

Checklist for updating commit hashes,
e.g. in `fetchFromGitHub` and `fetchTarball`
for all instantOS tools, such as
[instantWM](https://github.com/instantOS/instantWM),
[instantSettings](https://github.com/instantOS/instantSETTINGS) and so on:

 - [ ] Before commiting, make sure all packages build:
   `nix-build default.nix -A instantnix`
 - [ ] Check `utils/customconfig.h` is up to date with instantsWM's config.def.h
   `meld utils/customconfig.h src/instantwm/config.def.h`
 - [ ] Commit nothing else but the changed hashes
 - [ ] Use the commit message `bump github commits` verbatim
   (commets as to what exactly was changed/updated are allowed **in a new line**)
 - [ ] After a live stream or once a new version of instantOS was released,
   test extensively, then merge `dev` to `master`

Commands
--------

### Debug a single package in nix-shell

```
nix-shell default.nix -A instantsettings
unpackPhase
cd $sourceDir
patchPhase
installPhase
```

General Plan
============

Once instantOS is stable and out of beta, instantNIX development should focus
on getting the out of the box experice as close to that of instantOS as possible.

In addition the plan is to leverage NixOS's module system and make as many
`iconf` and other more implicit configuration usable in a NixOS `configuration.nix`
file.
That also means as many features as possible should work exactly as in instantOS.

