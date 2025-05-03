{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk-engine-murrine,
  jdupes,
  nix-update-script,
}:
let
  defaultAttrs = {
    dontBuild = true;
    dontConfigure = true;
    nativeBuildInputs = [ jdupes ];
    propagatedUserEnvPkgs = [ gtk-engine-murrine ];
    meta = with lib; {
      description = "A GTK theme based on the Tokyo Night colour palette";
      homepage = "https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme";
      license = licenses.gpl3Only;
      platforms = platforms.all;
      maintainers = with maintainers; [ ataraxiasjel ];
    };
  };
in
{
  tokyonight-gtk-theme = stdenv.mkDerivation (
    lib.recursiveUpdate {
      pname = "tokyonight-gtk-theme";
      version = "0-unstable-2025-04-24";
      src = fetchFromGitHub {
        owner = "Fausto-Korpsvart";
        repo = "Tokyo-Night-GTK-Theme";
        rev = "006154c78dde52b5851347a7e91f924af62f1b8f";
        hash = "sha256-h5k9p++zjzxGFkTK/6o/ISl/Litgf6fzy8Jf6Ikt5V8=";
      };
      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/themes
        cp -r themes/* $out/share/themes
        jdupes -L -r $out/share

        runHook postInstall
      '';
      passthru.updateScript = nix-update-script {
        extraArgs = [ "--version=branch" ];
      };
    } defaultAttrs
  );
  tokyonight-gtk-icons = stdenv.mkDerivation (
    lib.recursiveUpdate {
      pname = "tokyonight-gtk-icons";
      version = "0-unstable-2025-04-24";
      src = fetchFromGitHub {
        owner = "Fausto-Korpsvart";
        repo = "Tokyo-Night-GTK-Theme";
        rev = "006154c78dde52b5851347a7e91f924af62f1b8f";
        hash = "sha256-h5k9p++zjzxGFkTK/6o/ISl/Litgf6fzy8Jf6Ikt5V8=";
      };
      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/icons
        cp -r icons/* $out/share/icons
        jdupes -L -r $out/share

        runHook postInstall
      '';
      passthru.updateScript = nix-update-script {
        extraArgs = [ "--version=branch" ];
      };
    } defaultAttrs
  );
}
