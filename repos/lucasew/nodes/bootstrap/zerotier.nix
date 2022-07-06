{...}:
{
  services.zerotierone = {
    enable = true;
    port = 6969;
    joinNetworks = [
      "e5cd7a9e1c857f07"
    ];
  };
  networking.extraHosts = ''
    192.168.69.1 vps.local
    192.168.69.1 utils.vps.local
    192.168.69.1 vaultwarden.vps.local
    192.168.69.1 *.vps.local
    192.168.69.2 nb.local
    192.168.69.3 mtpc.local
    192.168.69.4 cel.local
  '';
}
