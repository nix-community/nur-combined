{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk-engine-murrine,
  jdupes,
}:

builtins.mapAttrs
  (
    pname: attrs:
    stdenv.mkDerivation (
      attrs
      // {
        inherit pname;

        version = "unstable-2023-05-30";

        src = fetchFromGitHub {
          owner = "Fausto-Korpsvart";
          repo = "Tokyo-Night-GTK-Theme";
          rev = "e9790345a6231cd6001f1356d578883fac52233a";
          hash = "sha256-Q9UnvmX+GpvqSmTwdjU4hsEsYhA887wPqs5pyqbIhmc=";
        };

        dontBuild = true;

        nativeBuildInputs = [ jdupes ];

        propagatedUserEnvPkgs = [ gtk-engine-murrine ];

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
