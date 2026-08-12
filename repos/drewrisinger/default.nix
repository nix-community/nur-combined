# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ overlays ? import ./overlays  # set or list
, pkgs ? import <nixpkgs> { overlays = (if builtins.isAttrs overlays then builtins.attrValues overlays else overlays); }
}:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  inherit overlays; # nixpkgs overlays

  # Packages/updates accepted to nixpkgs/master, but need the update or not made it to all stable branches
  lib-scs = pkgs.callPackage ./pkgs/libraries/scs { };
  xcfun = pkgs.callPackage ./pkgs/libraries/xcfun { };

  # New/unstable packages below
  tuna = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/tuna { };
  libtweedledum = pkgs.callPackage ./pkgs/libraries/tweedledum { };

  # Raspberry Pi Packages
  raspberryPi = pkgs.recurseIntoAttrs {
    argonone-rpi4 = pkgs.callPackage ./pkgs/raspberrypi/argonone-rpi4 { inherit (python3Packages) rpi-gpio smbus2; };
    pigpio-c = pkgs.callPackage ./pkgs/raspberrypi/pigpio { };
    steamlink = pkgs.callPackage ./pkgs/raspberrypi/steamlink {};
    vc-log = pkgs.callPackage ./pkgs/raspberrypi/vc-log { };
  };

  python3Packages = pkgs.recurseIntoAttrs rec {
    # New packages NOT in NixOS/nixpkgs (and likely never will be)
    asteval = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/asteval { };
    autoray = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/autoray { };
    csaps = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/csaps { };
    dynaconf = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/dynaconf { };
    # nose-timer = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/nose-timer { };
    oitg = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/oitg { };
    pyscf = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pyscf { inherit xcfun; };
    pygsti = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pygsti { inherit cvxpy csaps; };
    pygsti-cirq = pygsti.overridePythonAttrs (oldAttrs: {
      version = "unstable-2020-04-20";
      src = pkgs.fetchFromGitHub {
        owner = "pyGSTio";
        repo = "pygsti";
        rev = "79ff1467c79a33d3afb05831f78202dfc798b4a1";
        sha256 = "1dp6w5rh6kddxa5hp3kr249xnmbjpn6jdrpppsbm4hrfw9yh6hjw";
      };
      propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ cirq ];
    });
    pytest-plt = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pytest-plt { };
    pytest-profiling = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pytest-profiling { graphviz = pkgs.graphviz; };
    pubchempy = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pubchempy { };
    python-box = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/python-box { };
    qutip = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qutip { };  # removed from nixpkgs b/c it was broken (presumably unused)
    qutip-qip = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qutip-qip { inherit qutip; };
    openfermion = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/openfermion { inherit cirq pubchempy; };
    # openfermion-cirq has been deprecated. Its functionality is now rolled into openfermion as of v1.0
    # setuptools-rust has been removed b/c it has been integrated into nixpkgs. That probably has a better derivation to copy
    pyquil = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pyquil { inherit qcs-api-client rpcq; };
    quimb = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/quimb { inherit autoray; };
    rfc3339 = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/rfc3339 { };
    rpcq = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/rpcq { };
    qcs-api-client = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qcs-api-client { inherit rfc3339; };
    tweedledum = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/tweedledum { inherit libtweedledum; };
    olsq = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/olsq { inherit cirq qiskit-terra qiskit-ibmq-provider; };

    # VISA & Lab Instrument control
    pyvisa = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pyvisa { };
    pyvisa-py = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pyvisa-py { inherit pyvisa; };

    # More recent version than in Nixpkgs
    inherit (pkgs.python3.pkgs.callPackage ./pkgs/python-modules/cirq { inherit duet pyquil; })
      cirq
      cirq-aqt
      cirq-core
      cirq-google
      cirq-ionq
      cirq-pasqal
      cirq-rigetti
      cirq-web
    ;
    cvxpy = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/cvxpy { inherit ecos osqp scs; };
    ecos = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/ecos { };
    qdldl = pkgs.python3Packages.callPackage ./pkgs/python-modules/qdldl { };
    osqp = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/osqp { inherit qdldl; };
    scs = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/scs { };

    # NOTE: remove once makes release version
    algopy = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/algopy { };
    numdifftools = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/numdifftools { inherit algopy; };
    duet = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/duet { };

    # Qiskit proper, build order
    retworkx = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/retworkx { };
    qiskit-terra = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit-terra {
      inherit retworkx tweedledum;
    };
    qiskit-aer = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit-aer {
      inherit cvxpy qiskit-terra;
    };
    qiskit-ignis = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit-ignis {
      inherit qiskit-aer qiskit-terra;
    };
    qiskit-ibmq-provider = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit-ibmq-provider {
      inherit qiskit-terra qiskit-aer;
    };
    qiskit = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit {
      inherit
        qiskit-aer
        qiskit-terra
        qiskit-ignis
        qiskit-ibmq-provider
        qiskit-finance
        qiskit-machine-learning
        qiskit-nature
        qiskit-optimization
        ;
    };
    qiskit-terraNoVisual = qiskit-terra.override { withVisualization = false; };
    qiskit-ibmq-providerNoVisual = qiskit-ibmq-provider.override { withVisualization = false; qiskit-terra = qiskit-terraNoVisual; matplotlib = null; };
    qiskit-finance = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit-finance { inherit qiskit-optimization qiskit-terra qiskit-aer; };
    qiskit-optimization = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit-optimization { inherit qiskit-terra qiskit-aer; };
    qiskit-machine-learning = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit-machine-learning { inherit qiskit-terra qiskit-aer; };
    qiskit-nature = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit-nature { inherit qiskit-terra qiskit-aer retworkx pyscf; };
    qiskit-dynamics = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit-dynamics { inherit qiskit-terra; };
    qiskit-experiments = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit-experiments { inherit qiskit-terra qiskit-aer qiskit-ibmq-provider; };

    # Raspberry Pi Packages
    colorzero = pkgs.python3Packages.callPackage ./pkgs/raspberrypi/colorzero { };
    gpiozero = pkgs.python3Packages.callPackage ./pkgs/raspberrypi/gpiozero {
      inherit colorzero pigpio-py rpi-gpio;
    };
    pigpio-py = pkgs.python3.pkgs.callPackage ./pkgs/raspberrypi/pigpio/python.nix { inherit (raspberryPi) pigpio-c; };
    rpi-gpio = pkgs.python3Packages.callPackage ./pkgs/raspberrypi/rpi-gpio { };
    rpi-gpio2 = pkgs.python3Packages.callPackage ./pkgs/raspberrypi/rpi-gpio2 { };
    smbus2 = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/smbus2 { };
  };

}
