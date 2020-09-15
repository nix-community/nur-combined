# pnpkgs

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Build Status](https://travis-ci.com/pniedzwiedzinski/pnpkgs.svg?branch=master)](https://travis-ci.com/pniedzwiedzinski/pnpkgs)

## Larbs mail

If you use [Luke's configuration](https://github.com/LukeSmithXYZ/mutt-wizard) of neomutt as your mail client, you can get it also on NixOS. Install `nur.repos.pn.larbs-mail` and all will be installed. !!! __You need to add this to your__ `/etc/nixos/configuration.nix` __file__:

```nix
environment.etc."neomuttrc".text = builtins.readFile "${pkgs.nur.repos.pn.mutt-wizard}/share/mutt-wizard/mutt-wizard.muttrc";
```

If you have already generated muttrc file in your home you will need to change first source line:

```diff
-source /usr/local/share/mutt-wizard/mutt-wizard.muttrc
+source /etc/neomuttrc
```
