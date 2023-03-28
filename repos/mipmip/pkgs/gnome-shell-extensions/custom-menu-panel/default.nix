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
  description = "Custom menu on Gnome Top Bar with your favorite program shortcuts." ;
  longDescription = description;

  extensionHomepage = "https://github.com/andreabenini/gnome-plugin.custom-menu-panel";
  extensionUuid = "custom-menu-panel@AndreaBenini";
  extensionName = "custom-menu-panel";
  extensionVersion = "4";

  sourceDir= "custom-menu-panel@AndreaBenini";

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
      owner = "andreabenini";
      repo = "gnome-plugin.custom-menu-panel";
      rev = "dc91d44";
      sha256 = "sha256-2gwEVfRHC9dqZfNlPqHTrsiHQxx73+2UfR0rPQrdp28=";
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



