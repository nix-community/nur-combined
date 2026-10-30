{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchzip,
  hashcat,
  hcxtools,
  airsnare,
  zizzania,
}:

# AirJack asks CoreLocation for authorization before it can read BSSIDs, and
# macOS attributes that request to the process's own identity. A nix-built
# interpreter has none (ad-hoc signature, no Info.plist, no usage strings), so
# the prompt is refused silently and AirJack only waits out --auth-timeout.
# /usr/bin/python3 -- the Xcode-provided CPython 3.9.6 -- is a platform binary
# with an entry in Location Services, so this build runs it and supplies the
# libraries through PYTHONPATH.
#
# That is why an old nixpkgs is imported here: current nixpkgs no longer has
# CPython 3.9, and the PyObjC bindings must be compiled for the same minor
# version the system interpreter runs. `airjack_newpy` is the same tool built
# against the current nixpkgs Python instead, and stays the better choice
# wherever Location Services is not involved.
let
  # nixos-24.11 revision: the last branch that still ships CPython 3.9 (3.9.21,
  # ABI-compatible with the system's 3.9.6).
  nixpkgs2411 = fetchzip {
    url = "https://github.com/NixOS/nixpkgs/archive/50ab793786d9de88ee30ec4e4c24fb4236fc2674.tar.gz";
    hash = "sha256-/bVBlRpECLVzjV19t5KMdMFWSwKLtb5RyXdjz3LJT+g=";
  };

  pkgsOld = import nixpkgs2411 { system = stdenv.hostPlatform.system; };
  py = pkgsOld.python39Packages;

  # pyobjc 10.3.2 is the last release supporting Python 3.9 (11.x requires
  # 3.10+). pyobjc-core, Cocoa, CoreWLAN and CoreLocation all come from this
  # one source tree, one directory per project.
  pyobjcSrc = fetchzip {
    url = "https://github.com/ronaldoussoren/pyobjc/archive/refs/tags/v10.3.2.tar.gz";
    hash = "sha256-JGTUKzB1imz6/OxN3pmUoqLrhRbE1qmus2IL3B9MsiA=";
  };

  mkPyobjc =
    {
      pname,
      pythonImportsCheck,
      propagatedBuildInputs ? [ ],
    }:
    py.buildPythonPackage {
      inherit pname pythonImportsCheck propagatedBuildInputs;

      version = "10.3.2";
      src = pyobjcSrc;
      sourceRoot = "${pyobjcSrc}/${pname}";

      pyproject = true;
      build-system = [
        py.setuptools
        py.wheel
      ];

      buildInputs = [ pkgsOld.darwin.libffi ];
      nativeBuildInputs = [ pkgsOld.darwin.DarwinTools ]; # sw_vers

      # The setup helper shells out to /usr/bin/sw_vers, which the sandbox does
      # not have (same substitution nixpkgs' pyobjc packages use).
      postPatch = ''
        if [ -f pyobjc_setup.py ]; then
          substituteInPlace pyobjc_setup.py \
            --replace "/usr/bin/sw_vers" "sw_vers" \
            --replace "/usr/bin/xcrun" "xcrun"
        fi
      '';

      env.NIX_CFLAGS_COMPILE = "-I${pkgsOld.darwin.libffi.dev}/include";

      meta = {
        description = "PyObjC bindings for the ${pname} framework on macOS";
        homepage = "https://github.com/ronaldoussoren/pyobjc";
        license = lib.licenses.mit;
        platforms = lib.platforms.darwin;
      };
    };

  pyobjc-core = mkPyobjc {
    pname = "pyobjc-core";
    pythonImportsCheck = [ "objc" ];
  };

  pyobjc-framework-Cocoa = mkPyobjc {
    pname = "pyobjc-framework-Cocoa";
    pythonImportsCheck = [
      "Cocoa"
      "Foundation"
    ];
    propagatedBuildInputs = [ pyobjc-core ];
  };

  pyobjc-framework-CoreWLAN = mkPyobjc {
    pname = "pyobjc-framework-CoreWLAN";
    pythonImportsCheck = [ "CoreWLAN" ];
    propagatedBuildInputs = [
      pyobjc-core
      pyobjc-framework-Cocoa
    ];
  };

  pyobjc-framework-CoreLocation = mkPyobjc {
    pname = "pyobjc-framework-CoreLocation";
    pythonImportsCheck = [ "CoreLocation" ];
    propagatedBuildInputs = [
      pyobjc-core
      pyobjc-framework-Cocoa
    ];
  };

  pythonEnv = py.python.withPackages (_: [
    # 24.11's prettytable drags pytest-lazy-fixtures into its check inputs, and
    # that package's poetry-core -> virtualenv -> time-machine chain refuses
    # CPython 3.9 at evaluation time. Its tests are irrelevant here.
    (py.prettytable.overridePythonAttrs (_: {
      nativeCheckInputs = [ ];
      doCheck = false;
    }))
    py.pyfiglet
    # AirJack only sniffs and reads pcaps with scapy; the plotting/optional
    # extras would drag matplotlib in, whose time-machine dependency no longer
    # evaluates for CPython 3.9 at all.
    (py.scapy.override {
      withPlottingSupport = false;
      withOptionalDeps = false;
    })
    pyobjc-framework-CoreWLAN
    pyobjc-framework-CoreLocation
  ]);

  sitePackages = "${pythonEnv}/lib/python3.9/site-packages";

  toolPath = lib.makeBinPath [
    hashcat
    hcxtools
    airsnare
    zizzania
  ];
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

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 airjack.py "$out/share/airjack/airjack.py"
    install -Dm644 airjack.1 "$out/share/man/man1/airjack.1"

    substitute ${./wrapper.sh.in} "$out/bin/airjack" \
      --subst-var-by shell "${pkgsOld.bash}/bin/bash" \
      --subst-var-by binPath "${toolPath}" \
      --subst-var-by site "${sitePackages}" \
      --subst-var-by script "$out/share/airjack/airjack.py" \
      --subst-var-by fallback "${pythonEnv}/bin/python3"
    chmod +x "$out/bin/airjack"

    runHook postInstall
  '';

  meta = {
    description = "macOS Wi-Fi security testing tool for analyzing WPA/WPA2 network security";
    longDescription = ''
      AirJack scans nearby Wi-Fi networks using CoreWLAN, helps pick a target,
      and orchestrates AirSnare/zizzania plus hcxpcapngtool to capture
      WPA/WPA2/WPA3 handshakes, then converts them for hashcat-based cracking.

      This build runs the PyObjC bindings, prettytable, pyfiglet and scapy on
      macOS's own /usr/bin/python3 (CPython 3.9, taken from nixos-24.11), which
      is what lets CoreLocation authorization -- and therefore BSSID reads --
      work. The dependencies are provided to that interpreter through
      PYTHONPATH, not installed into it. hashcat, hcxtools (hcxpcapngtool),
      AirSnare and zizzania are packaged and put on PATH by the wrapper.
    '';
    homepage = "https://github.com/rtulke/AirJack";
    license = lib.licenses.mit;
    mainProgram = "airjack";
    platforms = lib.platforms.darwin;
  };
})
