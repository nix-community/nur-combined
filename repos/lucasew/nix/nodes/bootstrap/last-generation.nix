{...}: {
  system.activationScripts.link-last-generation = ''
    ln -s $systemConfig /etc/last-nixos-generation
  '';
}
