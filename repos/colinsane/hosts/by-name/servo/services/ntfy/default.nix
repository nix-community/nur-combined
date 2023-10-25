# ntfy: UnifiedPush notification delivery system
# - used to get push notifications out of Matrix and onto a Phone (iOS, Android, or a custom client)
{ config, ... }:
{
  imports = [
    ./ntfy-waiter.nix
    ./ntfy-sh.nix
  ];
  sops.secrets."ntfy-sh-topic" = {
    mode = "0440";
    owner = config.users.users.ntfy-sh.name;
    group = config.users.users.ntfy-sh.name;
  };
}
