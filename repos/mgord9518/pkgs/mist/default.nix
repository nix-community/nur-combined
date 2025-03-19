{ stdenv, fetchFromGitHub, zig_0_14 }:

stdenv.mkDerivation rec {
  pname = "mist";
  version = "0.0.13";

  nativeBuildInputs = [ zig_0_14 ];

  src = fetchFromGitHub {
    owner  = "mgord9518";
    repo   = "mist";
    rev    = "62f03fc42b66a8a254c69c49d244eb34c0c2a58e";
    sha256 = "jNuug3Z9e3Vp9TDBW27i/dpodMV/U4A1ne3ynCrspWI=";
    downloadToTemp = true;
  };

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  buildPhase = ''
    # By default Zig tries to write its global cache to $XDG_CACHE_HOME,
    # which isn't writable in the Nix build environment
    export ZIG_GLOBAL_CACHE_DIR=".zig_cache/global"

    # Zig creates a build tree which doesn't play nice with Nix's progress,
    # so let's prevent that
    export TERM="dumb"

    zig build --release=safe --verbose
  '';

  installPhase = ''
    [ -d zig-out/bin ] && mkdir -p "$out/bin"
    [ -d zig-out/lib ] && mkdir -p "$out/lib"

    mv zig-out/* "$out/"
  '';
}
