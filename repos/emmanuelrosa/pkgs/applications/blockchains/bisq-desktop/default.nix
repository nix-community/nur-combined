{ stdenv
, lib
, callPackage
, makeWrapper
, fetchurl
, rsync
, protobuf3_10
, makeDesktopItem
, imagemagick
}:
let
  bisq-launcher = callPackage ./launcher.nix { };
  common = callPackage ./common.nix { };

  # This takes all of the Java dependencies from deps.nix,
  # and creates a single mvn directory tree so that gradle
  # can find the project's dependencies.
  deps =
    let
      mkDepDerivation = { name, url, sha256, mavenDir }:
        stdenv.mkDerivation {
          name = "bisq-dep-${name}";

          src = fetchurl { inherit sha256 url; };

          unpackCmd = ''
            mkdir output
            cp $curSrc "output/${name}"
          '';

          installPhase = ''
            mkdir -p "$out/${mavenDir}"
            cp -r . "$out/${mavenDir}/"
          '';
        };

      d = map mkDepDerivation (import ./deps.nix);
    in
    stdenv.mkDerivation {
      name = "bisq-deps";
      dontUnpack = true;

      installPhase = ''
        mkdir $out

        for p in ${toString d}; do
          ${rsync}/bin/rsync -a $p/ $out/
        done
      '';
    };
in
stdenv.mkDerivation rec {
  inherit (common) pname version src jdk grpc gradle;

  nativeBuildInputs = [ makeWrapper gradle ];

  desktopItem = makeDesktopItem {
    name = "Bisq";
    exec = "bisq-desktop";
    icon = "bisq";
    desktopName = "Bisq";
    genericName = "Decentralized bitcoin exchange";
    categories = "Network;Utility;";
  };

  buildPhase = ''
    export GRADLE_USER_HOME=$(mktemp -d)
    (
      mkdir lib
      substituteInPlace build.gradle \
        --replace 'mavenCentral()' 'mavenLocal(); maven { url uri("${deps}") }' \
        --replace 'jcenter()' 'mavenLocal(); maven { url uri("${deps}") }' \
        --replace 'artifact = "com.google.protobuf:protoc:''${protocVersion}"' "path = '${protobuf3_10}/bin/protoc'" \
        --replace 'artifact = "io.grpc:protoc-gen-grpc-java:''${grpcVersion}"' "path = '${grpc}/bin/protoc-gen-rpc-java'"
      sed -i 's/^.*com.github.JesusMcCloud.tor-binary:tor-binary-linux64.*$//g' gradle/witness/gradle-witness.gradle
      gradle  --offline --no-daemon desktop:build  --exclude-task desktop:test
    )
  '';

  installPhase = ''
    mkdir -p $out/lib $out/bin
    cp -r lib/* $out/lib

    for jar in $out/lib/*.jar; do
      classpath="$classpath:$jar"
    done

    makeWrapper ${jdk}/bin/java $out/bin/bisq-desktop-wrapped \
      --add-flags "-classpath $classpath bisq.desktop.app.BisqAppMain"
    makeWrapper ${bisq-launcher} $out/bin/bisq-desktop \
      --prefix PATH : $out/bin

    install -Dm644 -t $out/share/applications \
      ${desktopItem}/share/applications/*

    for n in 16 24 32 48 64 96 128 256; do
      size=$n"x"$n
      ${imagemagick}/bin/convert $src/desktop/package/linux/icon.png -resize $size bisq.png
      install -Dm644 -t $out/share/icons/hicolor/$size/apps bisq.png
    done;
  '';

  meta = with lib; {
    description = "A decentralized bitcoin exchange network";
    homepage = "https://bisq.network";
    license = licenses.mit;
    maintainers = with maintainers; [ juaningan emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
