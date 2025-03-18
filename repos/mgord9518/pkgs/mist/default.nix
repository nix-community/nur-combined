{ stdenv, fetchFromGitHub, zig_0_14 }:

stdenv.mkDerivation rec {
  pname = "mist";
  version = "0.0.12";

  nativeBuildInputs = [ zig_0_14 ];

  src = fetchFromGitHub {
    owner  = "mgord9518";
    repo   = "mist";
    rev    = "ce1998b651c291b9a198435b98fc832ba2afaaf4";
    sha256 = "sha256-aUu1ymJ5K8J65C/CHF7m3tX+boY0hebZiQ4c3upaL2k=";
    downloadToTemp = true;
  };

  buildPhase = ''
    # By defaul,t Zig tries to write its global cache to $XDG_CACHE_HOME,
    # which isn't writable in the Nix build environment
    export ZIG_GLOBAL_CACHE_DIR="zig_global_cache"

    # Otherwize Zig creates a build tree which doesn't play nice with Nix's
    # progress
    export TERM="dumb"

    zig build --release=safe --verbose
  '';

  installPhase = ''
    mv zig-out/* "$out"
  '';
}
