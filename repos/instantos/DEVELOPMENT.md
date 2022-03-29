Development Notes
=================

Just some random notes on instantNix development.
If you want to contribute, you should read this document!

Pull Requests
-------------

Please open pull requests against the `dev` branch. 
**NOT** the `master` or `main` branches!
Before every new (beta release) or after every one of bennis live streams,
we merge `dev` into `master` and resolve possible conflicts.
Only exception is that hotfixes can be PRed directly to master.

Update
------

We have a python script in `./utils/update-commits.py` that updates the
main nix-hases of instantOS' github repositories such as such as
[instantWM](https://github.com/instantOS/instantWM),
[instantSettings](https://github.com/instantOS/instantSETTINGS)
semi-automatically.
If you use it you still have to add the changes and commit.
Might be worthwhile to setup github actions for that.
In the mean-time...

Checklist for updating commit hashes,
e.g. in `fetchFromGitHub` and `fetchTarball`
for all instantOS tools:

 - [ ] Before commiting, make sure all packages build:
   `nix-build default.nix -A instantnix`
 - [ ] Check `utils/customconfig.h` is up to date with instantsWM's config.def.h
   `meld utils/customconfig.h src/instantwm/config.def.h`
 - [ ] Commit nothing else but the changed hashes
 - [ ] Use the commit message `bump github commits` verbatim
   (commets as to what exactly was changed/updated are after **in a new line**)
 - [ ] After a live stream or once a new version of instantOS was released, merge `dev` to `master`:
   1. [ ] Test **EVERYTHING EXTENSIVELY**
   2. [ ] Change the github links of `hotkeys.md` and `thanks.md` in `./instantUtils/default.nix` to include the github commits and update the Nix-hases for both files
   3. [ ] Test if everything still builds
   4. [ ] Add changes, commit and push to `dev`
   5. [ ] Merge dev to master resolving any merge conflicts

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

