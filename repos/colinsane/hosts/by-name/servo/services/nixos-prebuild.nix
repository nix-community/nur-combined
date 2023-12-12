{ pkgs, ... }:
{
  systemd.services.nixos-prebuild = {
    description = "build a nixos image with all updated deps";
    path = with pkgs; [ coreutils git nix ];
    script = ''
      working=$(mktemp -d /tmp/nixos-prebuild.XXXXXX)
      pushd "$working"
      git clone https://git.uninsane.org/colin/nix-files.git
      cd nix-files
      nix flake update
      nix run '.#check' -- -j1 --cores 5
      popd
      rm -rf "$working"
    '';
  };

  systemd.timers.nixos-prebuild = {
    wantedBy = [ "multi-user.target" ];
    timerConfig.OnCalendar = "11,23:00:00";
  };
}
