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
  common = callPackage ./common.nix {};
  jdk = common.jdk;
  version = common.version;
  pname = common.pname;
  src = common.src;
  grpc = common.grpc;
  gradle = common.gradle;

  # fake build to pre-download deps into fixed-output derivation
  prebuild = pkgs.stdenv.mkDerivation {
    name = "${pname}-prebuild-${version}";
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
    outputHash = "06sq1a6jrsxfpqcwslwmqgq76r40jjn8c2533livvvi5fcvpmwbf";
  };

  gen-deps-script = pkgs.writeScript "${pname}-gen-deps-script" ''
    echo "["
    for path in $(find -L ${prebuild} -type f | sort | grep -v gradle-witness); do
      name=$(basename $path)
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
  
    echo "]"
  '';

in pkgs.stdenv.mkDerivation {
  name = "${pname}-deps-${version}.nix";

  phases = [ "installPhase" ];
  
  installPhase = ''
    cp ${gen-deps-script} $out
  '';
}
