{ stdenv, lib
, fetchFromGitHub
, fetchpatch, runCommand, buildPackages
, looking-glass-client
, cmake, pkg-config
, libbfd, libGLU, libX11
, libxcb, libXfixes
, nvidia-capture-sdk
, enableNvfbc ? false
}: with lib; let
  namedPatches = import ./patches.nix { inherit fetchpatch; };
  # TODO: this seems like a problem mingw or cmake should handle?
  windres = buildPackages.writeShellScriptBin "windres" ''
    exec ${stdenv.cc.targetPrefix}windres \
      --preprocessor "$CC -E -xc-header -DRC_INVOKED" \
      "$@"
  '';
in stdenv.mkDerivation rec {
  pname = "looking-glass-host";
  version = "2021-07-04";
  src = fetchFromGitHub {
    owner = "gnif";
    repo = "LookingGlass";
    rev = "6c545806abc5441be994a1f9315cfd75d4b89682";
    sha256 = "01vlnrpzddlcj6hbbwabpn0sd19cjrzxd6kgdxqynkczg2h76wxp";
    fetchSubmodules = true;
  };

  patches = with namedPatches; [
    cmake-rc-revert
    cmake-rc
  ];

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = optionals stdenv.isLinux [
    libbfd libGLU libX11
    libxcb libXfixes
  ];

  makeFlags = [
    "VERBOSE=1"
  ];
  cmakeFlags = [
    "-DVERSION=${version}"
    "-DOPTIMIZE_FOR_NATIVE=OFF"
    "../host"
  ] ++ optionals stdenv.hostPlatform.isWindows ([
    "-DCMAKE_RC_COMPILER=${windres}/bin/windres"
  ] ++ optionals enableNvfbc [
    "-DUSE_NVFBC=ON"
    "-DNVFBC_SDK=${nvidia-capture-sdk.sdk}"
  ]);

  meta = looking-glass-client.meta or { } // {
    platforms = with platforms; linux ++ windows;
  };

  passthru = {
    inherit namedPatches;
  };
}
