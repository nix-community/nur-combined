{ lib
, stdenv
, fetchFromGitHub
, gtk-engine-murrine
, jdupes
, nix-update-script
}:

builtins.mapAttrs
  (pname: attrs: stdenv.mkDerivation (attrs // {
    inherit pname;

    version = "0-unstable-2024-09-10";

    src = fetchFromGitHub {
      owner = "Fausto-Korpsvart";
      repo = "Rose-Pine-GTK-Theme";
      rev = "bc651787b5781f596865ea0b9c9c465b3ad29c85";
      hash = "sha256-y/P/Mux5T2CBkp5XFFbm16URrQZpCNuXNIt80Agp61c=";
    };

    dontBuild = true;

    nativeBuildInputs = [ jdupes ];

    propagatedUserEnvPkgs = [ gtk-engine-murrine ];

    passthru.updateScript = nix-update-script {
      extraArgs = [ "--version=branch" ];
    };

    meta = with lib; {
      description = "A GTK theme with the Rosé Pine colour palette";
      homepage = "https://github.com/Fausto-Korpsvart/Rose-Pine-GTK-Theme";
      license = licenses.gpl3Only;
      platforms = platforms.all;
      maintainers = with maintainers; [ ataraxiasjel ];
    };
  }))
{
  rosepine-gtk-theme = {
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/themes
      cp -r themes/* $out/share/themes
      jdupes -L -r $out/share

      runHook postInstall
    '';
  };
  rosepine-gtk-icons = {
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/icons
      cp -r icons/* $out/share/icons
      jdupes -L -r $out/share

      runHook postInstall
    '';
  };
}
