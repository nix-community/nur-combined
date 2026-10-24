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
in
{
  pname,
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
  passthrough = removeAttrs args [
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
        inherit (source) repo rev hash;
      });

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
      "-DBUILD_TESTING=OFF"
      "-DCMAKE_BUILD_TYPE=Release"
      "-DCMAKE_INSTALL_LIBEXECDIR=libexec"
      "-DCMAKE_INSTALL_SYSCONFDIR=${placeholder "out"}/etc"
    ]
    ++ extraCmakeFlags;

    meta = {
      homepage = "https://cutefish.org/";
      platforms = lib.platforms.linux;
      license = lib.licenses.bsd3;
    }
    // meta;
  }
)
