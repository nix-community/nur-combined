{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.sunpaper;
  sunpaper = pkgs.sunpaper.overrideAttrs (oldAttrs: rec {
    buildInputs = oldAttrs.buildInputs ++ [ pkgs.makeWrapper ];
    postPatch = ''
      ${oldAttrs.postPatch}
      substituteInPlace sunpaper.sh \
        --replace-fail "sunpaper.sh" "sunpaper" \
        --replace-fail "$out/share/sunpaper/images/" "/run/current-system/sw/share/sunpaper/images/"
    '';
    postInstall = ''
      wrapProgram $out/bin/sunpaper \
        --prefix PATH : ${lib.makeBinPath (with pkgs; [ swww pywal wget bc ])}
    '';
  });
in {
  options.programs.sunpaper = {
    enable = mkEnableOption "Sunpaper dynamic wallpaper";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ sunpaper ];
    environment.pathsToLink = [ "/share/sunpaper" ];
  };
}
