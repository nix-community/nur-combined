{ lib
, stdenv
, fetchFromGitHub
, gtk-engine-murrine
, jdupes
, nix-update-script
}:

builtins.mapAttrs
  (pname: attrs: stdenv.mkDerivation (attrs // rec {
    inherit pname;

    version = "unstable-2023-05-19";

    src = fetchFromGitHub {
      owner = "Fausto-Korpsvart";
      repo = "Tokyo-Night-GTK-Theme";
      rev = "d28c0d19f7f5674444e639e3f881c0a7f857cd15";
      hash = "sha256-oylWVDlVzr6DxTb8Z8sAXp4wxX7MIcYctz+kw+sixOM=";
    };

    dontBuild = true;

    nativeBuildInputs = [ jdupes ];

    propagatedUserEnvPkgs = [ gtk-engine-murrine ];

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
  }))
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
