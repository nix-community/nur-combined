{ pkgs, ... }: {
  systemd.tmpfiles.rules = [
    "L+ /usr/libexec/platform-python - - - - ${pkgs.python3}/bin/python"
  ];
}
