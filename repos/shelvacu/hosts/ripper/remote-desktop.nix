{ ... }: {
  vacu.packages = ''
    kdePackages.krfb
  '';

  networking.firewall.allowedTCPPorts = [ 5900 ];
}
