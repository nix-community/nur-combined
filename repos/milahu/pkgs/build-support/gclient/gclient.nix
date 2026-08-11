/*
  pkgs/flutter-engine/flutter-engine.nix
  https://github.com/NixOS/nixpkgs/pull/212328
*/

{ lib
, stdenv
, fetchgit
, writeShellScriptBin
, python3
}:

stdenv.mkDerivation rec {
  pname = "gclient";
  version = "unstable-2023-08-21";

  # TODO buildPythonPackage chromium-depot-tools
  # https://github.com/input-output-hk/gclient2nix
  # https://discourse.nixos.org/t/installing-depot-tools/5134
  src = fetchgit {
    url = "https://chromium.googlesource.com/chromium/tools/depot_tools";
    rev = "2d5c673fdb0072bb7b0c7463e6e7e18d0170b288";
    sha256 = "sha256-5JKENV//U2L2X+9Q+e0U5R7uY0hkPBeIXZpE9WhVzuQ=";
  };

  buildPhase = ''

    mkdir -p $out/bin
    cat >$out/bin/gclient <<'EOF'
    #!/bin/sh
    exec ${python3.withPackages (py: with py; [ google-auth-httplib2 ])}/bin/python ${src}/gclient.py "$@"
    EOF
    chmod +x $out/bin/gclient
  '';

  meta = with lib; {
    description = "Tools for working with Chromium development";
    homepage = "https://chromium.googlesource.com/chromium/tools/depot_tools";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
