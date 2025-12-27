# Originally based on:
# https://github.com/NixOS/nixpkgs/blob/a5c345b6d5e2d7d0e0a8c336a2bd6a0a42ea7623/pkgs/applications/virtualization/qemu/default.nix
# Changes marked with 'SCREAMER:'.
# Also changed `--replace` to `--replace-fail`, but didn't mark individually.
{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
# SCREAMER:
  nixpkgs-qemu9_1,
  maintainers,
  # unstableGitUpdater,
}:
# SCREAMER:
let nixpkgsPatch = name: "${nixpkgs-qemu9_1}/pkgs/applications/virtualization/qemu/${name}"; in
stdenv.mkDerivation rec {
  pname = "canokey-qemu";
  version = "0-unstable-2023-06-06";
  rev = "151568c34f5e92b086b7a3a62a11c43dd39f628b";

  src = fetchFromGitHub {
    owner = "canokeys";
    repo = "canokey-qemu";
    inherit rev;
    fetchSubmodules = true;
    hash = "sha256-4V/2UOgGWgL+tFJO/k90bCDjWSVyIpxw3nYi9NU/OxA=";
  };

  patches = [
    # SCREAMER:
    (nixpkgsPatch "canokey-qemu-memcpy.patch")
  ];

  postPatch = ''
    substituteInPlace canokey-core/CMakeLists.txt \
      --replace-fail "COMMAND git describe --always --tags --long --abbrev=8 --dirty >>" "COMMAND echo '$rev' >>"
    # SCREAMER:
    substituteInPlace canokey-core/canokey-crypto/mbedtls/CMakeLists.txt --replace-fail \
      'cmake_minimum_required(VERSION 2.8.12)' \
      'cmake_minimum_required(VERSION 3.5)'
  '';

  preConfigure = ''
    cmakeFlagsArray+=(
      -DCMAKE_C_FLAGS=${
        lib.escapeShellArg (
          [
            "-Wno-error=unused-but-set-parameter"
            "-Wno-error=unused-but-set-variable"
          ]
          ++ lib.optionals stdenv.cc.isClang [
            "-Wno-error=documentation"
          ]
        )
      }
    )
  '';

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ cmake ];

  # passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    homepage = "https://github.com/canokeys/canokey-qemu";
    description = "CanoKey QEMU Virt Card";
    license = licenses.asl20;
    # SCREAMER:
    maintainers = with maintainers; [ Rhys-T ];
  };
}
