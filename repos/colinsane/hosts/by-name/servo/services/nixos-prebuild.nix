{ lib, pkgs, ... }:

lib.optionalAttrs false  # disabled until i can be sure it's not gonna OOM my server in the middle of the night
{
  systemd.services.nixos-prebuild = {
    description = "build a nixos image with all updated deps";
    path = with pkgs; [ coreutils git nix ];
    script = ''
      working=$(mktemp -d nixos-prebuild.XXXXXX --tmpdir)
      pushd "$working"
      git clone https://git.uninsane.org/colin/nix-files.git \
        && cd nix-files \
        && nix flake update \
        || true
      RC=$(nix run "$working/nix-files#check" -- -j1 --cores 5 --builders "")
      popd
      rm -rf "$working"
      exit "$RC"
    '';
  };

  systemd.timers.nixos-prebuild = {
    wantedBy = [ "multi-user.target" ];
    timerConfig.OnCalendar = "11,23:00:00";
  };
}
