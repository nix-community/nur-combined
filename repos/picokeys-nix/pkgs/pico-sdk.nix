{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,

  # Options

  # The submodules in the pico-sdk contain important additional functionality
  # such as tinyusb, but not all these libraries might be bsd3.
  # Off by default.
  withSubmodules ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pico-sdk";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "pico-sdk";
    rev = finalAttrs.version;
    fetchSubmodules = withSubmodules;
    hash =
      if withSubmodules then
        "sha256-8ru1uGjs11S2yQ+aRAvzU53K8mreZ+CC3H+ijfctuqg="
      else
        "sha256-epO7yw6/21/ess3vMCkXvXEqAn6/4613zmH/hbaBbUw=";
  };

  nativeBuildInputs = [ cmake ];

  # SDK contains libraries and build-system to develop projects for RP2040 chip
  # We only need to compile pioasm binary
  sourceRoot = "${finalAttrs.src.name}/tools/pioasm";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/pico-sdk
    cp -a ../../../* $out/lib/pico-sdk/
    chmod 755 $out/lib/pico-sdk/tools/pioasm/build/pioasm
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/raspberrypi/pico-sdk";
    description = "SDK provides the headers, libraries and build system necessary to write programs for the RP2040-based devices";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      vizid
    ];
    platforms = platforms.unix;
  };
})
