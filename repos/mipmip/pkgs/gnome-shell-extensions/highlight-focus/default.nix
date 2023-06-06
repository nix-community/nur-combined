{ stdenv
, lib
, fetchFromGitHub
, glib
, gettext
, sassc
, gitUpdater
, gnome
, unzip
}:

let
  extensionUuid = "highlight-focus@pimsnel.com";
  extensionName = "highlight-focus";
  sourceDir= "src";
in
  stdenv.mkDerivation rec {
    pname = "gnome-shell-extension-highlight-focus";
    version = "9";

    meta = with lib; {
      description = "Highlights the focussed window with a temporary border ";
      longDescription = "Highlight is a GNOME Shell Extension which draws a temporary colored border around a focussed window. Useful in an keyboard only workflow.";
      homepage = "https://github.com/mipmip/gnome-shell-extensions-highlight-focus";
      license = licenses.gpl2Plus;
      maintainers = with maintainers; [ mipmip ];
    };

    src = fetchFromGitHub {
      owner = "mipmip";
      repo = "gnome-shell-extensions-highlight-focus";
      rev = "cdac4fe";
      sha256 = "sha256-0VjlEaFj5VZUoXkPaFtB/tp/pt/Ykl+1vNjF4yLtQ/E=";
    };

    nativeBuildInputs = [
      glib
      gettext
      sassc
      gnome.gnome-shell
      unzip
    ];

    buildPhase = ''
      bash ./install.sh zip
      unzip highlight-focus@pimsnel.com.shell-extension.zip -d build
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
