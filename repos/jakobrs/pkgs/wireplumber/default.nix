{ stdenv, lib, fetchFromGitLab, fetchpatch
, ninja, meson, pkg-config, cmake, git
, glib, pipewire, lua5_3, systemd }:

stdenv.mkDerivation rec {
  pname = "wireplumber";
  version = "0.4.0";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "pipewire";
    repo = "wireplumber";
    rev = version;
    hash = "sha256:1iian9wln6bz08y20g55y1kr8bznbmr1md7bibq8kqjh1jfq10vc";
  };

  nativeBuildInputs = [ ninja meson pkg-config cmake git ];

  buildInputs = [ glib pipewire lua5_3 systemd ];

  mesonFlags = [ "-Dintrospection=disabled" "-Ddoc=disabled" "-Dsystem-lua=true" ];

  hardeningDisable = [ "format" ];

  meta = {
    description = "Session / policy manager implementation for PipeWire";
    license = lib.licenses.mit;
  };
}
