# ntfy: UnifiedPush notification delivery system
# - used to get push notifications out of Matrix and onto a Phone (iOS, Android, or a custom client)
{ config, lib, ... }:
{
  imports = [
    ./ntfy-waiter.nix
    ./ntfy-sh.nix
  ];
  sops.secrets."ntfy-sh-topic" = lib.mkIf config.services.ntfy-sh.enable {
    mode = "0440";
    owner = config.users.users.ntfy-sh.name;
    group = config.users.users.ntfy-sh.name;
  };
}
