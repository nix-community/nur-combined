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
  description = "GNOME Shell extension for displaying your computer's health stats" ;
  longDescription = "A glimpse into your computer's temperature, voltage, fan speed, memory usage, processor load, system resources, network speed and storage stats. This is a one stop shop to monitor all of your vital sensors. Uses asynchronous polling to provide a smooth user experience. Feature requests or bugs? Please use GitHub.";

  extensionHomepage = "https://github.com/corecoding/Vitals";
  extensionUuid = "Vitals@CoreCoding.com";
  extensionName = "Vitals";
  extensionVersion = "61";

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
      owner = "corecoding";
      repo = "Vitals";
      rev = "v61.0.0";
      sha256 = "sha256-aZLco45lo8lAps4PGV6MIco+r6ZVIvI4wPqt0dhvOp0=";
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



