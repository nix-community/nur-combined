{ stdenv
, fetchFromGitLab
, lib
, meson, ninja
, gobject-introspection ? null
, lua5_3 ? null
, lua5_4 ? null
, pkg-config
, glib
, elogind
, pipewire
, systemd
, python3
, doxygen
, enableIntrospection ? stdenv.hostPlatform == stdenv.buildPlatform
, enableDocs ? false
}@args: with lib; let
  mesonFeature = v: if v then "enabled" else "disabled";
  mesonBool = v: if v then "true" else "false";
  lua = args.lua5_4 or lua5_3;
  python = python3.withPackages (p: with p; [
    lxml
  ] ++ optionals enableDocs [
    sphinx sphinx_rtd_theme breathe
  ]);
in stdenv.mkDerivation rec {
  pname = "wireplumber";
  version = "0.4.4";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "pipewire";
    repo = pname;
    rev = version;
    sha256 = "0vr84xlnwlhrfq9l13rxh8cb8s389wlyafvi6bah444acmpx1lwv";
  };

  outputs = [ "out" "dev" ] ++ optional enableDocs "doc";

  nativeBuildInputs = [ meson ninja pkg-config python doxygen ]
  ++ optional enableIntrospection gobject-introspection;

  buildInputs = [ lua glib pipewire systemd elogind ];

  mesonFlags = [
    "-Dintrospection=${mesonFeature enableIntrospection}"
    "-Dsystem-lua=${mesonBool (lua != null)}"
    "-Ddoc=${mesonFeature enableDocs}"
    "-Dsystemd-user-unit-dir=${placeholder "out"}/lib/systemd/user"
    "-Dsystemd-system-unit-dir=${placeholder "out"}/lib/systemd/system"
    "-Dsystemd-user-service=true"
    "-Dsystemd-system-service=true"
  ];

  meta.broken = lib.versionOlder pipewire.version "0.3.37";
}
