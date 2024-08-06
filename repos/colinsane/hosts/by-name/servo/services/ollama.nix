# ollama: <https://github.com/ollama/ollama>
# use: `ollama run llama3.1`
# or: `ollama run llama3.1:70b`
# or use a remote session: <https://github.com/ggozad/oterm>
{ lib, ... }:
lib.mkIf false  #< WIP
{
  sane.persist.sys.byStore.plaintext = [
    { user = "ollama"; group = "ollama"; path = "/var/lib/ollama"; method = "bind"; }
  ];
  services.ollama.enable = true;
  services.ollama.user = "ollama";
  services.ollama.group = "ollama";

  users.groups.ollama = {};

  users.users.ollama = {
    group = "ollama";
    isSystemUser = true;
  };

  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;
}
