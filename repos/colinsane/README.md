![hello](doc/hello.gif)

# .❄️≡We|_c0m3 7o m`/ f14k≡❄️.

(er, it's not a flake anymore. welcome to my nix files.)

## What's Here

this is the top-level repo from which i configure/deploy all my NixOS machines:
- desktop
- laptop
- server
- mobile phone (Pinephone)

everything outside of [hosts/](./hosts/) and [secrets/](./secrets/) is intended for export, to be importable for use by 3rd parties.
the only hard dependency for my exported pkgs/modules should be [nixpkgs][nixpkgs].
building [hosts/](./hosts/) will require [sops][sops].

you might specifically be interested in these files (elaborated further in #key-points-of-interest):
- [my packages](./pkgs/by-name)
- [my implementation of impermanence](./modules/persist/default.nix)
- my way of deploying dotfiles/configuring programs per-user:
  - [modules/fs/](./modules/fs/default.nix)
  - [modules/programs/](./modules/programs/default.nix)
  - [modules/users/](./modules/users/default.nix)

if you find anything here genuinely useful, message me so that i can work to upstream it!

[nixpkgs]: https://github.com/NixOS/nixpkgs
[sops]: https://github.com/Mic92/sops-nix
[uninsane-org]: https://uninsane.org


## Using This Repo In Your Own Config

follow the instructions [here][NUR] to access my packages through the Nix User Repositories.

[NUR]: https://nur.nix-community.org/


## Layout
- `doc/`
  - instructions for tasks i find myself doing semi-occasionally in this repo.
- `hosts/`
  - configs which aren't factored with external use in mind.
  - that is, if you were to add this repo to a flake.nix for your own use,
    you won't likely be depending on anything in this directory.
- `integrations/`
  - code intended for consumption by external tools (e.g. the Nix User Repos).
- `modules/`
  - config which is gated behind `enable` flags, in similar style to nixpkgs' `nixos/` directory.
  - if you depend on this repo for anything besides packages, it's most likely for something in this directory.
- `overlays/`
  - predominantly a list of `callPackage` directives.
- `pkgs/`
  - derivations for things not yet packaged in nixpkgs.
  - derivations for things from nixpkgs which i need to `override` for some reason.
  - inline code for wholly custom packages (e.g. `pkgs/by-name/sane-scripts/` for CLI tools
    that are highly specific to my setup).
- `scripts/`
  - scripts which aren't reachable on a deployed system, but may aid manual deployments.
- `secrets/`
  - encrypted keys, API tokens, anything which one or more of my machines needs
    read access to but shouldn't be world-readable.
  - not much to see here.
- `templates/`
  - used to instantiate short-lived environments.
  - used to auto-fill the boiler-plate portions of new packages.


## Key Points of Interest

i.e. you might find value in using these in your own config:

- `modules/fs/`
  - use this to statically define leafs and nodes anywhere in the filesystem,
    not just inside `/nix/store`.
  - e.g. specify that `/var/www` should be:
    - owned by a specific user/group
    - set to a specific mode
    - symlinked to some other path
    - populated with some statically-defined data
    - populated according to some script
    - created as a dependency of some service (e.g. `nginx`)
  - this is akin to using [Home Manager's][home-manager] file API -- the part which lets you
    statically define `~/.config` files -- just with a different philosophy.
    namely, it avoids any custom activation scripts by leveraging `systemd-tmpfiles`.
- `modules/persist/`
  - my implementation of impermanence, built atop the above `fs` module, with a few notable features:
    - no custom activation scripts or services (uses `systemd-tmpfiles` and `.mount` units)
    - "persist" cache directories -- to free up RAM -- but auto-wipe them on mount
      and encrypt them to ephemeral keys so they're unreadable post shutdown/unmount.
    - persist to encrypted storage which is unlocked at login time.
- `modules/programs/`
  - like nixpkgs' `programs` options, but allows both system-wide or per-user deployment.
  - allows `fs` and `persist` config values to be gated behind program deployment:
    - e.g. `/home/<user>/.mozilla/firefox` is persisted only for users who
      `sane.programs.firefox.enableFor.user."<user>" = true;`
  - allows aggressive sandboxing any program:
    - `sane.programs.firefox.sandbox.enable = true;  # wraps the program so that it isolates itself into a new namespace when invoked`
    - `sane.programs.firefox.sandbox.whitelistWayland = true;  # allow it to render a wayland window`
    - `sane.programs.firefox.sandbox.extraHomePaths = [ "Downloads" ];  # allow it read/write access to ~/Downloads`
    - integrated with `fs` and `persist` modules so that programs' config files and persisted data stores are linked into the sandbox w/o any extra involvement.
- `modules/users/`
  - convenience layer atop the above modules so that you can just write
    `fs.".config/git"` instead of `fs."/home/colin/.config/git"`
  - simplified `systemd.services` API

[home-manager]: https://github.com/nix-community/home-manager


## Mirrors

this repo exists in a few known locations:
- primary: <https://git.uninsane.org/colin/nix-files>
- mirror: <https://github.com/nix-community/nur-combined/tree/master/repos/colinsane>


## Contact

if you want to contact me for questions, or collaborate to split something useful into a shared repo, etc,
you can reach me via any method listed [here](https://uninsane.org/about).
patches, for this repo or any other i host, will be warmly welcomed in any manner you see fit:
`git send-email`, DM'ing the patch over Matrix/Lemmy/ActivityPub/etc, even a literal PR where you
link me to your own clone.
