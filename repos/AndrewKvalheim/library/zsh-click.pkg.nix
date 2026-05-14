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
    replaceStrings [ "&!" ] [ "@AMPERSAND_EXCLAMATION@" ] (readFile ./assets/click.plugin.zsh)
  );
  dontUnpack = true;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -D "$src" "$out/share/zsh/plugins/click/click.plugin.zsh"
    install ${./assets/click.wav} "$out/share/zsh/plugins/click/click.wav"

    # Pending abathur/resholve#85
    sed --in-place 's/@AMPERSAND_EXCLAMATION@/\&!/g' "$out/share/zsh/plugins/click/click.plugin.zsh"

    runHook postInstall
  '';
}
