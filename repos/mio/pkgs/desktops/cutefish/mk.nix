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
  callPackage,
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
  passthru ? { },
  ...
}@args:
let
  source = sources.${pname} or (throw "cutefish source entry missing for ${pname}");
  # Attributes a package sets itself (patches, postPatch, postFixup, ...).
  # The inputs and phases composed below are shared, so packages only add to
  # them through the extra* arguments.
  extraAttrs = lib.removeAttrs args [
    "stdenv"
    "withPkgConfig"
    "withGettext"
    "extraNativeBuildInputs"
    "extraBuildInputs"
    "extraCmakeFlags"
    "meta"
    "passthru"
    "pname"
    "version"
    "src"
    "nativeBuildInputs"
    "buildInputs"
    "cmakeFlags"
  ];
in
stdenv.mkDerivation (
  extraAttrs
  // {
    inherit pname;
    # The suite is versioned 1.0 upstream (see cutefish-toolkit's CMake
    # project VERSION); the pins track the development branch, hence -unstable.
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

    passthru = passthru // {
      updateScript = callPackage ./update.nix { inherit pname; };
    };

    meta = {
      homepage = "https://cutefish.org/";
      license = lib.licenses.bsd3;
      platforms = lib.platforms.linux;
    }
    // meta;
  }
)
