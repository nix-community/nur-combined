{ stdenv, lib, callPackage, makeWrapper, fetchgit, unzip, zip, git, git-lfs
, openjdk11
, perl
, gradle
, gradleGen
, protobuf3_10
, gnome2
, ps
, tor
, makeDesktopItem
, imagemagick
}:
let
  jdk = openjdk11.overrideAttrs (oldAttrs: rec {
    buildInputs = lib.remove gnome2.gnome_vfs oldAttrs.buildInputs;
    NIX_LDFLAGS = builtins.replaceStrings [ "-lgnomevfs-2" ] [ "" ] oldAttrs.NIX_LDFLAGS;
  });
  version = "1.5.9";
  name = "bisq-desktop";

  src = (fetchgit rec {
    url = https://github.com/bisq-network/bisq;
    rev = "v${version}";
    sha256 = "0xhmc69gw7d3cdsc84pkpz5ga8v9d9hn7flh07n68c0f9ngz1smp";
    postFetch = ''
      cd $out
      git clone $url
      cd bisq
      git lfs install --force --local
      git lfs pull
      cp -v p2p/src/main/resources/* $out/p2p/src/main/resources/
      cd ..
      rm -rf bisq
    '';
  }).overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs or [] ++ [ git-lfs ];
  });

  bisq-launcher = callPackage ./launcher.nix {};
  grpc = callPackage ./grpc-java.nix {};

  gradle = (gradleGen.override {
    java = jdk;
  }).gradle_5_6;

  # fake build to pre-download deps into fixed-output derivation
  deps = stdenv.mkDerivation {
    name = "${name}-deps";
    inherit src;
    buildInputs = [ gradle perl unzip zip ];

    patchPhase = ''
      substituteInPlace ./build.gradle \
        --replace 'artifact = "com.google.protobuf:protoc:''${protocVersion}"' "path = '${protobuf3_10}/bin/protoc'"
      substituteInPlace ./build.gradle \
        --replace 'artifact = "io.grpc:protoc-gen-grpc-java:''${grpcVersion}"' "path = '${grpc}/bin/protoc-gen-rpc-java'"
    '';

    buildPhase = ''
      export GRADLE_USER_HOME=$(mktemp -d)
      gradle --no-daemon desktop:build --exclude-task desktop:test
    '';

    # perl code mavenizes pathes (com.squareup.okio/okio/1.13.0/a9283170b7305c8d92d25aff02a6ab7e45d06cbe/okio-1.13.0.jar -> com/squareup/okio/okio/1.13.0/okio-1.13.0.jar)
    installPhase = ''
      find $GRADLE_USER_HOME -type f -regex '.*\.\(jar\|pom\)' \
        | perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/$x/$3/$4/$5" #e' \
        | sh

   '';

    dontStrip = true;

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "0z58kymzgrp6qhyfl8yqnw20glmdjv1wcysiidxv1acrghs6zwh0";
  };

in stdenv.mkDerivation rec {
  inherit name src;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ gradle ps tor ];

  desktopItem = makeDesktopItem {
    name = "Bisq";
    exec = "bisq-desktop";
    icon = "bisq";
    desktopName = "Bisq";
    genericName = "Distributed crypto exchange";
    categories  = "Network;Utility;";
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
    mkdir -p $out/lib
    cp -r lib/* $out/lib
    for jar in $out/lib/*.jar; do
      classpath="$classpath:$jar"
    done
    mkdir -p $out/bin
    makeWrapper ${jdk}/bin/java $out/bin/bisq-desktop-wrapped \
      --add-flags "-classpath $classpath bisq.desktop.app.BisqAppMain"
    makeWrapper ${bisq-launcher} $out/bin/bisq-desktop \
      --prefix PATH : $out/bin

    install -Dm644 -t $out/share/applications \
      ${desktopItem}/share/applications/*

    for n in 16 24 32 48 64 96 128 256; do
      size=$n"x"$n
      ${imagemagick}/bin/convert $src/desktop/package/linux/icon.png -resize $size icon.png
      install -Dm644 \
        -t $out/share/icons/hicolor/$size/apps/bisq.png \
        icon.png
    done;
  '';

  meta = with lib; {
    description = "The decentralized bitcoin exchange network";
    homepage = "https://bisq.network";
    license = licenses.mit;
    maintainers = [ maintainers.juaningan ];
    platforms = [ "x86_64-linux" ];
  };
}
