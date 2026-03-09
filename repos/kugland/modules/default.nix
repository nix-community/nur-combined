{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.modules ];
  flake.modules = {
    nixos = {
      adblock = ./adblock.nix;
      autossh-tunnels = ./autossh-tunnels.nix;
      google-authenticator-singlesecret = ./google-authenticator-singlesecret;
    };
    homeManager = {
      firefox-handlers = ./firefox-handlers.nix;
    };
  };
}
