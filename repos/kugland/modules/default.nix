{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.modules ];
  flake.modules = {
    nixos = {
      adblock = ./adblock.nix;
      autossh-tunnels = ./autossh-tunnels.nix;
      bindMounts = ./bind-mounts.nix;
      google-authenticator-singlesecret = ./google-authenticator-singlesecret;
      issue = ./issue.nix;
      upnp = ./upnp.nix;
    };
    homeManager = {
      firefox-handlers = ./firefox-handlers.nix;
    };
  };
}
