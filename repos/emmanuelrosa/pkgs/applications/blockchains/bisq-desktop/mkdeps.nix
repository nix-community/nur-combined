# This script is for the Bisq Nix package maintainers.
# This script builds Bisq within a fixed-point derivation,
# which allows Gradle to download dependencies.
# After which, it produces deps.nix, which declares all of the
# dependencies downloaded by Gradle, creating a fixed-point
# derivation for each one. This effectively "pins" the dependencies.
# deps.nix is used by default.nix, which is the Bisq package,
# to provide the (Java) dependencies so that the package can be
# built in a reproducable way.

# USAGE:
# 1. `nix build -f mkdeps.nix`
# If needed, update the `outputHash` at REF1, below. Then repeat step 1.
# 2. `./result > deps.nix`
# 3. `cd <nixpkgs repo root>`
# 4. Build as usual: `nix build bisq-desktop`

with import <nixpkgs> { };
let
  jdk = pkgs.openjdk11.overrideAttrs (oldAttrs: rec {
    buildInputs = pkgs.lib.remove pkgs.gnome2.gnome_vfs oldAttrs.buildInputs;
    NIX_LDFLAGS = builtins.replaceStrings [ "-lgnomevfs-2" ] [ "" ] oldAttrs.NIX_LDFLAGS;
  });
  version = "1.6.2";
  name = "bisq-desktop";

  src = (pkgs.fetchgit rec {
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

  grpc = callPackage ./grpc-java.nix {};

  gradle = (pkgs.gradleGen.override {
    java = jdk;
  }).gradle_5_6;

  # fake build to pre-download deps into fixed-output derivation
  prebuild = pkgs.stdenv.mkDerivation {
    name = "${name}-prebuild";
    inherit src;
    buildInputs = [ gradle pkgs.perl pkgs.unzip pkgs.zip ];

    patchPhase = ''
      substituteInPlace ./build.gradle \
        --replace 'artifact = "com.google.protobuf:protoc:''${protocVersion}"' "path = '${pkgs.protobuf3_10}/bin/protoc'"
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

    # REF1
    outputHash = "1y7md3r4viacp9xcrvprma8h33nnf2fall5s1f35cypn10978iy3";
  };

  header = ./bisq-gen-deps-header.nix.txt;
  footer = ./bisq-gen-deps-footer.nix.txt;

  gen-deps-script = pkgs.writeScript "${name}-gen-deps-script" ''
    excludes="gradle-witness"
    cat ${header}
    for path in $(find -L ${prebuild} -type f); do
      name=$(basename $path)
      skip=0
  
      for n in $excludes; do
        if [ "$name" == "$n.pom" ]
        then
          skip=1
        elif [ "$name" == "$n.jar" ]
        then
          skip=1
        fi
      done
  
      if [ "$skip" == "1" ] 
      then 
        continue 
      fi

      sha256=""
      upstreamPath=$(realpath --relative-to ${prebuild} $path)
      upstreamDir=$(dirname $upstreamPath)

      for repo in https://repo.maven.apache.org/maven2 https://jitpack.io https://jcenter.bintray.com; do
        url="$repo/$upstreamPath"
        sha256=$(${pkgs.nix}/bin/nix-prefetch-url $url 2> /dev/null)
        status=$?

        if [[ $status -eq 0 ]]
        then
          break
        fi  
      done

      if [[ "$sha256" == "" ]]
      then
        echo "ERROR: Unable to download $upstreamPath from any known sources."
        exit 1
      fi

      echo "  { url = \"$url\";"
      echo "    sha256 = \"$sha256\";"
      echo "    name = \"$name\";"
      echo "    mavenDir = \"$upstreamDir\";"
      echo "  }"
    done
  
    cat ${footer}
  '';

in pkgs.stdenv.mkDerivation {
  name = "${name}-deps.nix";

  phases = [ "installPhase" ];
  
  installPhase = ''
    cp ${gen-deps-script} $out
  '';
}
