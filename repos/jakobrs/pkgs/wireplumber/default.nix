{ stdenv, fetchFromGitLab, fetchpatch
, ninja, meson, pkg-config, cmake, git
, gobject-introspection, pipewire
, cpptoml }:

stdenv.mkDerivation rec {
  pname = "wireplumber";
  version = "0.3.0";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "pipewire";
    repo = "wireplumber";
    rev = version;
    hash = "sha256:0pyvg1n3aq4mi7pxna7wjq5ipfaak51930vh360qypnbwvvg57aw";
  };

  patches = [
    (fetchpatch {
      url = "https://gitlab.freedesktop.org/pipewire/wireplumber/-/commit/fbe1e5177b9703366d121d9b5857a2d72e895590.patch";
      sha256 = "1b1wshrbj78kvmlyy6y77qxa1ip5qaq5w6lqfh0r2fv2g4p6nwi3";
    })
  ];

  nativeBuildInputs = [ ninja meson pkg-config cmake cpptoml git ];

  buildInputs = [ gobject-introspection pipewire ];

  mesonFlags = [ "-Ddoc=disabled" ];

  hardeningDisable = [ "format" ];

  meta = {
    description = "Session / policy manager implementation for PipeWire";
    license = stdenv.lib.licenses.mit;
  };
}
