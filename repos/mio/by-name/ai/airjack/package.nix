{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  python3Packages,
  makeWrapper,
  darwin,
}:

# AirJack drives CoreWLAN and CoreLocation through PyObjC. Nixpkgs only ships
# some of the PyObjC framework bindings (Cocoa, Quartz, ...), so the two this
# tool needs are built here from the same PyObjC source tree as pyobjc-core.
let
  inherit (python3Packages) buildPythonPackage pyobjc-core;

  mkPyobjcFramework =
    { framework, pythonImportsCheck }:
    buildPythonPackage {
      pname = "pyobjc-framework-${framework}";
      inherit pythonImportsCheck;
      inherit (pyobjc-core) version src;

      pyproject = true;
      sourceRoot = "${pyobjc-core.src.name}/pyobjc-framework-${framework}";

      build-system = [ python3Packages.setuptools ];
      buildInputs = [ darwin.libffi ];
      nativeBuildInputs = [ darwin.DarwinTools ]; # sw_vers

      dependencies = [
        pyobjc-core
        python3Packages.pyobjc-framework-Cocoa
      ];

      # Same fix as nixpkgs' pyobjc-framework-Cocoa: the setup helper shells
      # out to /usr/bin/sw_vers and /usr/bin/xcrun, which do not exist in the
      # sandbox.
      postPatch = ''
        substituteInPlace pyobjc_setup.py \
          --replace-fail "-buildversion" "-buildVersion" \
          --replace-fail "-productversion" "-productVersion" \
          --replace-fail "/usr/bin/sw_vers" "sw_vers" \
          --replace-fail "/usr/bin/xcrun" "xcrun"
      '';

      env.NIX_CFLAGS_COMPILE = toString [
        "-I${darwin.libffi.dev}/include"
        "-Wno-error=unused-command-line-argument"
      ];

      meta = {
        description = "PyObjC wrappers for the ${framework} framework on macOS";
        homepage = "https://github.com/ronaldoussoren/pyobjc/tree/main/pyobjc-framework-${framework}";
        license = lib.licenses.mit;
        platforms = lib.platforms.darwin;
      };
    };

  pyobjcFramework-CoreWLAN = mkPyobjcFramework {
    framework = "CoreWLAN";
    pythonImportsCheck = [ "CoreWLAN" ];
  };

  pyobjcFramework-CoreLocation = mkPyobjcFramework {
    framework = "CoreLocation";
    pythonImportsCheck = [ "CoreLocation" ];
  };

  python = python3.withPackages (_: [
    python3Packages.prettytable
    python3Packages.pyfiglet
    python3Packages.scapy
    pyobjcFramework-CoreWLAN
    pyobjcFramework-CoreLocation
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "airjack";
  version = "0-unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "rtulke";
    repo = "AirJack";
    rev = "92da55cff23415543a30003322c493afbfaeaced";
    hash = "sha256-vo5sn6dkX7a6hMQP6s2tsk9ktVd16TqNvYX1CXXWBPY=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm644 airjack.py "$out/share/airjack/airjack.py"
    install -Dm644 airjack.1 "$out/share/man/man1/airjack.1"

    # Upstream's launcher script prefers /usr/bin/python3 so that macOS
    # Location Services authorization applies; that interpreter cannot see
    # store packages, so the store Python is used directly here. On macOS 15+
    # CoreWLAN redacts BSSIDs for such processes, and AirJack falls back to
    # recovering them from monitor-mode beacons (it needs tcpdump and sudo).
    makeWrapper ${python}/bin/python3 "$out/bin/airjack" \
      --add-flags "$out/share/airjack/airjack.py"

    runHook postInstall
  '';

  meta = {
    description = "macOS Wi-Fi security testing tool for analyzing WPA/WPA2 network security";
    longDescription = ''
      AirJack scans nearby Wi-Fi networks using CoreWLAN, helps pick a target,
      and orchestrates AirSnare/zizzania plus hcxpcapngtool to capture
      WPA/WPA2/WPA3 handshakes, then converts them for hashcat-based cracking.
      The external capture and cracking tools (hashcat, hcxtools, AirSnare or
      zizzania) are not bundled and have to be installed separately.
    '';
    homepage = "https://github.com/rtulke/AirJack";
    license = lib.licenses.mit;
    mainProgram = "airjack";
    platforms = lib.platforms.darwin;
  };
})
