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
  description = "Integrate github's notifications within the gnome desktop environment ";
  longDescription = description;

  extensionHomepage = "https://github.com/alexduf/gnome-github-notifications";
  extensionUuid = "github.notifications@alexandre.dufournet.gmail.com";
  extensionName = "github-notifications";
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
      repo = "gnome-github-notifications";
      rev = "bb5b50e";
      sha256 = "sha256-Zgw7ljVM6T66HuahYztLshP7Lr6EjtxexBvBCxjw4e8=";
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



