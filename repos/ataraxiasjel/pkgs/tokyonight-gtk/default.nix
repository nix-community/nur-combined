{
  lib,
  stdenv,
  fetchFromGitHub,
  jdupes,
  nix-update-script,
}:
builtins.mapAttrs
  (
    pname: attrs:
    stdenv.mkDerivation (
      attrs
      // {
        inherit pname;

        version = "0-unstable-2025-10-23";

        src = fetchFromGitHub {
          owner = "Fausto-Korpsvart";
          repo = "Tokyo-Night-GTK-Theme";
          rev = "6c340e058e84c1975a038a8e5d1e384477225dc0";
          hash = "sha256-7H2n9wTaW8Db1RejWK071ITV1j5KIuzfql0Tx9WT6zM=";
        };

        dontBuild = true;
        dontConfigure = true;

        nativeBuildInputs = [ jdupes ];

        passthru.updateScript = nix-update-script {
          extraArgs = [ "--version=branch" ];
        };

        meta = with lib; {
          description = "A GTK theme based on the Tokyo Night colour palette";
          homepage = "https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme";
          license = licenses.gpl3Only;
          platforms = platforms.all;
          maintainers = with maintainers; [ ataraxiasjel ];
        };
      }
    )
  )
  {
    tokyonight-gtk-theme = {
      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/themes
        cp -r themes/* $out/share/themes
        jdupes -L -r $out/share

        runHook postInstall
      '';
    };
    tokyonight-gtk-icons = {
      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/icons
        cp -r icons/* $out/share/icons
        jdupes -L -r $out/share

        runHook postInstall
      '';
    };
  }
