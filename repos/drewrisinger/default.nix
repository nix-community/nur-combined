# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # NOTE: default pkgs to updated versions as required by packages
  # pkgs = rawpkgs.appendOverlays [ overlays.python-updates ];

  # Packages/updates accepted to nixpkgs/master, but need the update
  lib-scs = pkgs.callPackage ./pkgs/libraries/scs { };

  # New/unstable packages below
  libcint = pkgs.callPackage ./pkgs/libraries/libcint { };
  xcfun = pkgs.callPackage ./pkgs/libraries/xcfun { };
  muparserx = pkgs.callPackage ./pkgs/libraries/muparserx { };
  tuna = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/tuna { };

  python3Packages = pkgs.recurseIntoAttrs rec {
    # New packages NOT in NixOS/nixpkgs (and likely never will be)
    # asteval = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/asteval { };
    # nose-timer = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/nose-timer { };
    oitg = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/oitg { };
    pyscf = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pyscf { inherit libcint xcfun; };
    pygsti = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pygsti { inherit cvxpy; };
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
    pubchempy = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pubchempy { };
    python-box = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/python-box { };
    qutip = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qutip { };  # removed from nixpkgs b/c it was broken (presumably unused)
    openfermion = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/openfermion { inherit pubchempy; };
    openfermion-cirq = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/openfermion-cirq { inherit cirq openfermion; };
    setuptools-rust = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/setuptools-rust { };
    tweedledum = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/tweedledum { };

    # VISA & Lab Instrument control
    pyvisa = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pyvisa { };
    pyvisa-py = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pyvisa-py { inherit pyvisa; };

    # More recent version than in Nixpkgs
    cirq = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/cirq { };
    cvxpy = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/cvxpy { inherit ecos osqp scs; };
    ecos = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/ecos { };
    osqp = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/osqp { };
    scs = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/scs { scs = lib-scs; };

    # NOTE: remove once makes release version
    algopy = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/algopy { };
    numdifftools = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/numdifftools { inherit algopy; };

    # Qiskit updates over what's in nixpkgs, in rough build order. All exist in nixpkgs, but only on > 20.03
    dlx = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/dlx { };
    docloud = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/docloud { };
    docplex = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/docplex { inherit docloud; };
    fastdtw = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/fastdtw { };
    fastjsonschema = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/fastjsonschema { };
    ipyvue = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/ipyvue { };
    ipyvuetify = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/ipyvuetify { inherit ipyvue; };
    pproxy = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pproxy { };
    python-constraint = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/python-constraint { };
    pylatexenc = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pylatexenc { };
    retworkx = pkgs.python3.pkgs.toPythonModule (pkgs.python3.pkgs.callPackage ./pkgs/python-modules/retworkx { });

    # Needs added to nixpkgs
    multitasking = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/multitasking { };
    yfinance = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/yfinance { inherit multitasking; };

    # Qiskit proper, build order
    qiskit-terra = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit-terra {
      inherit fastjsonschema python-constraint pylatexenc retworkx tweedledum;
    };
    qiskit-aer = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit-aer {
      inherit cvxpy qiskit-terra muparserx;
    };
    qiskit-ignis = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit-ignis {
      inherit qiskit-aer qiskit-terra;
    };
    qiskit-aqua = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit-aqua {
      inherit cvxpy dlx docplex fastdtw pyscf qiskit-aer qiskit-ignis qiskit-terra yfinance;
    };
    qiskit-ibmq-provider = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit-ibmq-provider {
      inherit ipyvuetify pproxy qiskit-terra;
    };
    qiskit = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/qiskit {
      inherit qiskit-aer qiskit-terra qiskit-ignis qiskit-aqua qiskit-ibmq-provider;
    };
    qiskit-terraNoVisual = qiskit-terra.override { withVisualization = false; };
    qiskit-ibmq-providerNoVisual = qiskit-ibmq-provider.override { withVisualization = false; qiskit-terra = qiskit-terraNoVisual; matplotlib = null; };
  };

}
