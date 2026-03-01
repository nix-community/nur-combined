{ pkgs, ... }:

let
  configFile = pkgs.writeText "ncdu.conf" ''
    --disable-delete
    --disable-shell
    --shared-column off
    --show-itemcount
    --apparent-size
    --exclude-kernfs
  '';
in
{
  environment.systemPackages = [
    (pkgs.ncdu.overrideAttrs (
      {
        postPatch ? "",
        ...
      }:
      {
        postPatch = postPatch + ''
          substituteInPlace src/main.zig \
            --replace-fail '"/etc/ncdu.conf"' '"${configFile}"'
        '';
      }
    ))
  ];

  # environment.etc."ncdu.conf".text = ''
  #   --disable-delete
  #   --disable-shell
  #   --shared-column off
  #   --show-itemcount
  #   --apparent-size
  #   --exclude-kernfs
  # '';

}
