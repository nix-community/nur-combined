{ lib
, resholve
, stdenv

  # Dependencies
, pipewire
, zsh
}:

let
  inherit (builtins) readFile replaceStrings;
  inherit (lib) getExe;
in
stdenv.mkDerivation {
  name = "zsh-click";

  src = resholve.writeScript "click.plugin.zsh" {
    interpreter = getExe zsh;
    inputs = [ pipewire ];
  } (
    # Pending abathur/resholve#85
    replaceStrings [ "&!" ] [ "@AMPERSAND_EXCLAMATION@" ] (readFile ./resources/click.plugin.zsh)
  );
  dontUnpack = true;

  dontBuild = true;

  installPhase = ''
    install -D $src $out/share/zsh/plugins/click/click.plugin.zsh
    install ${./resources/click.wav} $out/share/zsh/plugins/click/click.wav

    # Pending abathur/resholve#85
    sed --in-place 's/@AMPERSAND_EXCLAMATION@/\&!/g' $out/share/zsh/plugins/click/click.plugin.zsh
  '';
}
