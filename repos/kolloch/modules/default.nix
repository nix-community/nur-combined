rec {
  # Add your NixOS modules here
  #
  # my-module = ./my-module;

  # Ripped from https://github.com/NixOS/nixpkgs/pull/82920
  jicofo = jitsi/jicofo.nix;
  jitsi-meet = jitsi/jitsi-meet.nix;
  jitsi-videobridge = jitsi/jitsi-videobridge.nix;

  jitsi = {
    imports = [ jicofo jitsi-meet jitsi-videobridge ];
  };
}

