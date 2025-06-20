{
  fetchFromGitHub,
  glib,
  glibc,
  gsettings-desktop-schemas,
  javaPackages,
  lib,
  libglibutil,
  makeWrapper,
  maven,
  pkgs,
  stdenv,
  xorg,
}:
let
  jdk = (pkgs.jdk23.override { enableJavaFX = true; });
in

maven.buildMavenPackage rec {
  pname = "convert-with-moss";
  version = "13.1.0";

  src = fetchFromGitHub {
    owner = "git-moss";
    repo = "ConvertWithMoss";
    rev = version;
    hash = "sha256-eqE4lJHau5L6cCtMxOVl0197us3uopvk7vK7IX7dpuo=";
  };

  inherit jdk;

  mvnHash = "sha256-S3xlYpzPpF+tMX1oKfc3NSI3/nWXhH0HQRNnMyzrBKQ=";
  mvnJdk = jdk;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    glib
    glibc
    gsettings-desktop-schemas
    javaPackages.openjfx23
    libglibutil
    xorg.libXxf86vm
    jdk
  ];

  GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share

    install -dm755 $out/share/${pname}

    cp target/lib/convertwithmoss*.jar $out/share/${pname}/convertwithmoss.jar
    cp target/lib/*-linux.jar $out/share/${pname}/
    cp target/lib/uitools-*.jar $out/share/${pname}/

    install -Dm644 linux/de.mossgrabers.ConvertWithMoss.desktop -t $out/share/applications/
    install -Dm644 linux/de.mossgrabers.ConvertWithMoss.appdata.xml -t $out/share/metainfo/
    install -Dm644 icons/convertwithmoss.png -t $out/share/pixmaps/

    makeWrapper ${jdk}/bin/java \
        $out/bin/${pname} \
        --add-flags "-jar $out/share/${pname}/convertwithmoss.jar" \
        --add-flags "-Xmx64G" \
        --add-flags "--module-path ${javaPackages.openjfx23}/lib --add-modules javafx.controls,javafx.fxml,javafx.graphics"

    runHook postInstall
  '';

  meta = {
    description = "Converts multisamples from a source format (WAV, multisample, KMP, wavestate, NKI, SFZ, SoundFont 2) to a different destination format";
    homepage = "https://github.com/git-moss/ConvertWithMoss";
    license = lib.licenses.lgpl3Only;
    # maintainers = with lib.maintainers; [ foresense ];
    mainProgram = "convert-with-moss";
    platforms = lib.platforms.all;
  };
}
