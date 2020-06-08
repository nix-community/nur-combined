{
  # Add your NixOS modules here

  jitsi-meet = ./jitsi-meet.nix;
  jitsi-videobridge = ./jitsi-videobridge.nix;

  prometheus-exporters-lnd = ./prometheus-exporters-lnd.nix;
  rtl = ./rtl.nix;
}

