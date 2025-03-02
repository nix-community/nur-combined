{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ncdu ];

  environment.etc."ncdu.conf".text = ''
    --disable-delete
    --disable-shell
    --shared-column off
    --show-itemcount
    --apparent-size
    --exclude-kernfs
  '';
}
