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
  description = "Take the apps search out of overview (patched to make it work when installed by Nix)";
  longDescription = "Gnome Shell extension that takes the apps search widget out of Overview. Like the macOS spotlight, or Alfred.";

  extensionHomepage = "https://github.com/icedman/search-light";
  extensionUuid = "search-light@icedman.github.com";
  extensionName = "search-light";
  extensionVersion = "99";

  sourceDir= ".";

in
  stdenv.mkDerivation rec {
    pname = "gnome-shell-extension-${extensionName}";
    version = extensionVersion;

    meta = with lib; {
      description = description;
      longDescription = longDescription;
      homepage = extensionHomepage;
      license = licenses.gpl2Plus;
      maintainers = with maintainers; [ mipmip ];
    };

    src = fetchFromGitHub {
      owner = "mipmip";
      repo = "search-light";
      rev = "ff32724";
      sha256 = "sha256-eSQ562tNFSkIJdyWNsaYrpJQS20o+j8LpKIzn6vAc6U=";
    };

    dontBuild = true;

    nativeBuildInputs = [
      glib
      gettext
      sassc
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/gnome-shell/extensions/
      cp -r -T ${sourceDir} $out/share/gnome-shell/extensions/${extensionUuid}
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



