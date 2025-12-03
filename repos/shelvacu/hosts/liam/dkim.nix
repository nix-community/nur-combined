{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.vacu.liam) domains;
in
{
  services.opendkim = {
    enable = true;
    keyPath = "/run/secrets/dkimkeys";
    domains = "file:${pkgs.writeText "SignDomains" (lib.concatStringsSep "\n" domains)}";
    selector = "2024-03-liam";
    socket = "local:/run/opendkim/opendkim.sock";
    group = config.services.postfix.group;
    user = config.services.postfix.user;
  };
  systemd.services.postfix.wants = [ "opendkim.service" ];
  systemd.services.postfix.after = [ "opendkim.service" ];
}
# 2024-03-liam._domainkey
# v=DKIM1; k=rsa; s=email; p=MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqoFR9cwOb+IpvaqrI55zlouWMUk5hjKHQARajqeOev2I6Gc3QIvU8btyhKCJu7pwxr+DxK/9HeqTmweCSXZmLlVZ6LjW80aAg+8l2DyMKZPaTowSQcExfNMwHqI1ByUPx49LQQEzvwv8Lx3To2+JghZNXHUx7gcraoCUQnRNzCMoMsGF25Yyt4piW6SXKWsbWHVXaL2i953PtT6agJYqssnBqPx6wqibrkeB9MbtSw97L5oQDaDLmJzEK54vRjFFV4X6/Q1d3D6M5PH0XGm6WEhrNEPgMAAZ6rBqi+AoXUz9E9B+kE/Zc6krCTiV0Y1uL83RCILaEJIjRsHqgrGRYEIBUb4Z5d4CgB3szixzaFTmG+XAgDLGnAHRNGeOn0bUmj35miLUopzGJgHCUQYjaaXMH4FSQMYBFPVqZ1aSiZO0EC/mbLlFbBy51RYPJQK0IusN4IqaBYw6jZYMEVlLWkNb34bfNtPKwoG4T3UjxmSRpfiNCFjYd4DaOz/FBAvUL9bx+qU7O6EZRtslROaWN18uSt20hBH0SpvEovj7vBgWWqXG/chNS7YSSaf3Tlb3I5NbqbmvwFF0t8uuEtN0Wh26qMuOKx70K90B9FpJBpfIk/w8FQ80kP6spbMN1v1T5fA7oZMV1fOn1IezH4wE5Yk/3dS+OXJ4YiLH/hWfjecCAwEAAQ==
