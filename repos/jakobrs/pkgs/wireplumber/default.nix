{ stdenv, lib, fetchFromGitLab, fetchpatch
, ninja, meson, pkg-config, cmake, git, doxygen, gobject-introspection
, python3
, lxml # for gobject-introspection
, sphinx, sphinx_rtd_theme, breathe # for docs
, glib, pipewire, lua5_4, systemd }:

stdenv.mkDerivation rec {
  pname = "wireplumber";
  version = "0.4.1";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "pipewire";
    repo = "wireplumber";
    rev = version;
    hash = "sha256:1j88pl8yfj3vcsh9y57a542msn1vk8qcwcy2qqgjg2y8lfg7qi6b";
  };

  nativeBuildInputs = [
    ninja meson pkg-config cmake git doxygen gobject-introspection
    python3 lxml sphinx sphinx_rtd_theme breathe
  ];

  buildInputs = [ glib pipewire lua5_4 systemd ];

  mesonFlags = [ "-Dsystem-lua=true" ];

  meta = {
    description = "Session / policy manager implementation for PipeWire";
    license = lib.licenses.mit;
  };
}
