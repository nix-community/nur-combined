{ stdenv, lib, fetchurl, fetchFromGitHub, zig_0_14, tree }:

stdenv.mkDerivation rec {
  pname = "mist";
  version = "0.0.11";

  nativeBuildInputs = [ zig_0_14 ];

  src = fetchFromGitHub {
    owner  = "mgord9518";
    repo   = "mist";
    rev    = "db4fc2bd04e9ff2821ced039c294553979497f30";
    sha256 = "sha256-YJoyCWUjEITYT4KpQZPxdVLxzxetOEHwWDJwrsv0rA8=";
    downloadToTemp = true;
  };

  buildPhase = ''
    # By defaul,t Zig tries to write its global cache to $XDG_CACHE_HOME,
    # which isn't writable in the Nix build environment
    export XDG_CACHE_HOME="TMP"

    # Otherwize Zig creates a build tree which doesn't play nice with Nix's
    # progress
    export TERM="dumb"

    zig build --verbose
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    mv zig-out/* "$out"
  '';
}
