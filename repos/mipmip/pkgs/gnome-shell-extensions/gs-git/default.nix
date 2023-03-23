{ stdenv
, lib
, fetchFromGitHub
, glib
, gettext
, sassc
, gitUpdater
, jq
, gnome
, unzip
}:

let
  extensionUuid = "git@eexpss.gmail.com";
  extensionName = "gs-git";
  sourceDir= "src";
in
  stdenv.mkDerivation rec {
    pname = "gnome-shell-extension-gs-git";
    version = "1";

    meta = with lib; {
      description = "Gnome Extension to monitor git directory for changes. (enhanced fork by mipmip)";
      longDescription = description;
      homepage = "https://github.com/mipmip/gs-git";
      license = licenses.gpl2Plus;
      maintainers = with maintainers; [ mipmip ];
    };

    src = fetchFromGitHub {
      owner = "mipmip";
      repo = "gs-git";
      rev = "223bb2e6878fb6cb32fa5ac4b45e4635c5eba7b3";
      sha256 = "sha256-Bz6+4Obv4GuvrHSeoyzCBLre+NvyvfniY1j5P70bfag=";
    };

    nativeBuildInputs = [
      glib
      gettext
      sassc
      gnome.gnome-shell
      jq
      unzip
    ];

    buildPhase = ''
      #cat ${sourceDir}/metadata.json | jq '.uuid = "${extensionUuid}"' > ${sourceDir}/metadata.json
      bash ./install.sh zip
      unzip git@eexpss.gmail.com.shell-extension.zip -d build
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/gnome-shell/extensions/
      cp -r -T build $out/share/gnome-shell/extensions/${extensionUuid}
      runHook postInstall
    '';

    makeFlags = [
      "INSTALLBASE=${placeholder "out"}/share/gnome-shell/extensions"
      ];

      passthru = {
        extensionUuid = "${extensionUuid}";
        extensionPortalSlug = "${extensionName}";

      };

    }
