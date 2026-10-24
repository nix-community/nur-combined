# Shared builder for the Cutefish packages, in the shape of
# pkgs/kde/lib/mk-kde-derivation.nix. Source revisions live in ./sources.nix.
# Packages pass only the inputs and phases that differ.
{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  gettext,
}:
let
  sources = import ./sources.nix;
  defaultStdenv = stdenv;
in
{
  pname,
  stdenv ? defaultStdenv,
  withPkgConfig ? true,
  withGettext ? true,
  extraNativeBuildInputs ? [ ],
  extraBuildInputs ? [ ],
  extraCmakeFlags ? [ ],
  meta ? { },
  ...
}@args:
let
  source = sources.${pname} or (throw "cutefish source entry missing for ${pname}");
  passthrough = lib.removeAttrs args [
    "stdenv"
    "withPkgConfig"
    "withGettext"
    "extraNativeBuildInputs"
    "extraBuildInputs"
    "extraCmakeFlags"
    "meta"
    "pname"
    "version"
    "src"
    "nativeBuildInputs"
    "buildInputs"
    "cmakeFlags"
  ];
in
stdenv.mkDerivation (
  passthrough
  // {
    inherit pname;
    version = args.version or "1.0-unstable-${source.date}";

    src =
      args.src or (fetchFromGitHub {
        owner = "cutefishos";
        inherit (source)
          repo
          rev
          hash
          ;
      });

    # pkg-config only sees .pc files from buildInputs, and find_program only
    # sees nativeBuildInputs. wayland-scanner and qtpaths6 are listed accordingly.
    strictDeps = true;

    nativeBuildInputs = [
      cmake
      ninja
    ]
    ++ lib.optionals withPkgConfig [ pkg-config ]
    ++ lib.optionals withGettext [ gettext ]
    ++ extraNativeBuildInputs;

    buildInputs = extraBuildInputs;

    # Upstream installs to /usr. The prefix is the store path; SYSCONFDIR must
    # not stay the GNU default of /etc.
    cmakeFlags = [
      (lib.cmakeBool "BUILD_TESTING" false)
      (lib.cmakeFeature "CMAKE_BUILD_TYPE" "Release")
      (lib.cmakeFeature "CMAKE_INSTALL_LIBEXECDIR" "libexec")
      (lib.cmakeFeature "CMAKE_INSTALL_SYSCONFDIR" "${placeholder "out"}/etc")
    ]
    ++ extraCmakeFlags;

    meta = {
      homepage = "https://cutefish.org/";
      license = lib.licenses.bsd3;
      platforms = lib.platforms.linux;
    }
    // meta;
  }
)
