{ stdenv, lib, fetchFromGitLab, fetchpatch
, ninja, meson, pkg-config, cmake, doxygen, gobject-introspection
, python3
, lxml # for gobject-introspection
, sphinx, sphinx_rtd_theme, breathe # for docs
, glib, pipewire, lua5_4, systemd }:

stdenv.mkDerivation rec {
  pname = "wireplumber";
  version = "0.4.2";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "pipewire";
    repo = "wireplumber";
    rev = version;
    hash = "sha256:04jq1rn8lr6wbn2acs5lzydpnhzmrs0fd80a1a55rli3fh1bm2qi";
  };

  nativeBuildInputs = [
    ninja meson pkg-config cmake doxygen gobject-introspection
    python3 lxml sphinx sphinx_rtd_theme breathe
  ];

  buildInputs = [ glib pipewire lua5_4 systemd ];

  mesonFlags = [ "-Dsystem-lua=true" ];

  meta = {
    description = "Session / policy manager implementation for PipeWire";
    license = lib.licenses.mit;
  };
}
