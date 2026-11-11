{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  makeSetupHook,
  binutils,
  xxd,
  strace,
}:

let
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "wrap-buddy";
    rev = "ba5ab56ddc572482c26b2cf08414befc5f66ad40";
    hash = "sha256-NlBlJbQsFKDgUtawzAEGF0iIO/xON2LXGw/axFOU4g8=";
  };

  wrapBuddy = stdenv.mkDerivation {
    pname = "wrap-buddy";
    inherit version src;

    depsBuildBuild = [ buildPackages.stdenv.cc ];

    nativeBuildInputs = [
      binutils
      xxd
    ];

    makeFlags = [
      "CXX_FOR_BUILD=${buildPackages.stdenv.cc}/bin/c++"
      "BINDIR=$(out)/bin"
      "LIBDIR=$(out)/lib/wrap-buddy"
      "INTERP=${stdenv.cc.bintools.dynamicLinker}"
      "LIBC_LIB=${stdenv.cc.libc}/lib"
    ]
    ++ lib.optional stdenv.hostPlatform.isx86_64 "BUILD_32BIT=1";

    nativeInstallCheckInputs = [ strace ];
    doInstallCheck = true;
    installCheckTarget = "check";
    enableParallelBuilding = true;

    meta = {
      description = "Patch ELF binaries with a stub loader for NixOS compatibility";
      homepage = "https://github.com/Mic92/wrap-buddy";
      mainProgram = "wrap-buddy";
      license = lib.licenses.mit;
      platforms = [
        "x86_64-linux"
        "i686-linux"
        "aarch64-linux"
      ];
    };
  };
in
makeSetupHook {
  name = "wrap-buddy-hook";
  propagatedBuildInputs = [ wrapBuddy ];
  passthru = { inherit wrapBuddy; };
  meta = {
    description = "Setup hook that patches ELF binaries with a stub loader";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
} "${src}/nix/wrap-buddy-hook.sh"
