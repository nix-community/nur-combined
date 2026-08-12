{ ... }:
{
  system.activationScripts.link-last-generation = ''
    echo "Setting up /etc/last-nixos-generation"
    rm /etc/last-nixos-generation
    ln -s $systemConfig /etc/last-nixos-generation
  '';
}
