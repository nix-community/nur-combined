/*
https://github.com/NixOS/nixpkgs/issues/201574

flutter is a giant project and takes forever to build
*/

{ stdenv
, lib
, fetchgit
, fetchFromGitHub
, writeShellScriptBin
, python3
, git
, cacert
, ninja
}:

let
  # TODO buildPythonPackage
  # https://github.com/input-output-hk/gclient2nix
  # https://discourse.nixos.org/t/installing-depot-tools/5134
  depot_tools = fetchgit {
    url = "https://chromium.googlesource.com/chromium/tools/depot_tools";
    rev = "30e3ce8b1c670be00c4957fe773ffb8ff986ed8f";
    sha256 = "sha256-R9CX/xzvLiOVQmAsviTFUFv6DiStxa0b6O0zHNaH6SY=";
  };
  gclient = writeShellScriptBin "gclient" ''
    ${python3.withPackages (py: with py; [ google-auth-httplib2 ])}/bin/python ${depot_tools}/gclient.py "$@"
  '';
in

stdenv.mkDerivation rec {
  pname = "flutter-engine";
  version = "981fe92ab998d655abded58f1f0ef2a8daeadd02";

  # https://github.com/flutter/engine
  src = fetchFromGitHub {
    owner = "flutter";
    repo = "engine";
    rev = version;
    sha256 = "sha256-9uY7Q8ZR51vB7vsjEPGAWyvhOKRfdj5B8o0KwypwdTY=";
  };

  deps = stdenv.mkDerivation {
    inherit src;
    name = "${pname}-${version}-deps";
    nativeBuildInputs = [
      gclient
      git
      cacert # fix: error:16000069:STORE routines::unregistered scheme
    ];
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = ""; # TODO
    # "gclient sync" will about 1 hour to fetch sources
    buildPhase = ''
      echo FIXME we need all scripts from depot_tools
      echo FIXME "FileNotFoundError: [Errno 2] No such file or directory: 'cipd'"
      exit 1
      (
        set -x
        gclient config https://github.com/flutter/engine
        gclient sync --revision engine@${version} --shallow --verbose
        cp -r . $out
      )
    '';
  };

  postUnpack = ''
    (
      cd $sourceRoot
      echo TODO merge with source. copy or symlink ${deps}
      exit 1
    )
  '';

  nativeBuildInputs = [
    ninja
  ];

  /*
    TODO
    https://github.com/flutter/flutter/wiki/Compiling-the-engine#compiling-for-macos-or-linux
    this will take forever ...
  */
  buildPhase = ''
    ./flutter/tools/gn --unoptimized # to prepare your build files.
    ninja -C out/host_debug_unopt # to build a desktop unoptimized binary.
  '';
}
