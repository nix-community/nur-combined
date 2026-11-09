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
  # Stock (prebuilt) JDK + OpenJFX provided via --module-path in the wrapper.
  # An FX-enabled JDK variant (jdk25.override { enableJavaFX = true; }) is never
  # built by Hydra, forcing a multi-hour local OpenJDK+OpenJFX compile.
  jdk = pkgs.jdk25;
in

maven.buildMavenPackage rec {
  pname = "convertwithmoss";
  version = "20.3.0";

  src = fetchFromGitHub {
    owner = "git-moss";
    repo = "ConvertWithMoss";
    rev = version;
    hash = "sha256-aPHFxpmCA7SuJhaMKHzx3KotgfCOUd9VJii12wuN8ew=";
  };

  inherit jdk;

  mvnHash = "sha256-oXvTOd5/OmCEICglPkY4NLX/TI18L9PC9SXoEr08ueM=";
  mvnJdk = jdk;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    glib
    glibc
    gsettings-desktop-schemas
    javaPackages.openjfx25
    libglibutil
    xorg.libXxf86vm
    jdk
  ];

  GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share

    install -dm755 $out/share/${pname}

    # The jar manifest uses addClasspath, so all sibling jars from
    # target/lib must be installed (upstream 20.3.0 layout).
    cp target/lib/*.jar $out/share/${pname}/
    mv $out/share/${pname}/convertwithmoss-*.jar $out/share/${pname}/convertwithmoss.jar

    install -Dm644 linux/de.mossgrabers.ConvertWithMoss.desktop -t $out/share/applications/
    install -Dm644 linux/de.mossgrabers.ConvertWithMoss.appdata.xml -t $out/share/metainfo/
    install -Dm644 icons/convertwithmoss.png -t $out/share/pixmaps/

    makeWrapper ${jdk}/bin/java \
        $out/bin/${pname} \
        --add-flags "-jar $out/share/${pname}/convertwithmoss.jar" \
        --add-flags "-Xmx64G" \
        --add-flags "--module-path ${javaPackages.openjfx25}/lib --add-modules javafx.controls,javafx.fxml,javafx.graphics"

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
