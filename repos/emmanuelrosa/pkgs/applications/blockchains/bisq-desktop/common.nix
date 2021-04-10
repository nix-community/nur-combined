{ lib, callPackage, fetchgit, unzip, zip, git, git-lfs
, openjdk11
, gradle
, gradleGen
, gnome2
}:
rec {
  pname = "bisq-desktop";
  version = "1.6.2";

  src = (fetchgit rec {
    url = https://github.com/bisq-network/bisq;
    rev = "v${version}";
    sha256 = "1zmf76i4yddr4zc2jcm09bgs7yya6bqv1zk68z17g3r39qmyxv1q";
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

  # We use a modified JDK package due to an issue with libcrypto.
  # See https://github.com/NixOS/nixpkgs/issues/73246
  jdk = openjdk11.overrideAttrs (oldAttrs: rec {
    buildInputs = lib.remove gnome2.gnome_vfs oldAttrs.buildInputs;
    NIX_LDFLAGS = builtins.replaceStrings [ "-lgnomevfs-2" ] [ "" ] oldAttrs.NIX_LDFLAGS;
  });

  grpc = callPackage ./grpc-java.nix {};

  gradle = (gradleGen.override {
    java = jdk;
  }).gradle_5_6;
}
