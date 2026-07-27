let 
  mvn2nix = import (fetchTarball "https://github.com/fzakaria/mvn2nix/archive/master.tar.gz") {};
in { pkgs ? import <nixpkgs> { } }:
let
  lib = pkgs.lib;
  autoreconfHook269 = if pkgs ? autoreconfHook269 then
    pkgs.autoreconfHook269
  else
    pkgs.autoreconfHook;

  scope = lib.makeScope pkgs.newScope (self: rec {
    # The `lib`, `modules`, and `overlay` names are special
    lib = pkgs.lib // import ./lib { inherit pkgs; }; # functions
    modules = import ./modules; # NixOS modules
    overlays = import ./overlays; # nixpkgs overlays

    otcl = self.callPackage ./pkgs/otcl { };
    tclcl = self.callPackage ./pkgs/tclcl { };
    ns-2 = self.callPackage ./pkgs/ns2 { };

    qt5 = lib.makeScope pkgs.qt5.newScope (self: rec {
      inherit (self.callPackage ./pkgs/omnetpp { }) omnetpp_5_6_2 omnetpp_6_0 omnetpp_5_7;
      omnetpp = omnetpp_5_6_2;
      inherit (self.callPackage ./pkgs/omnetpp-inet { }) omnetpp-inet_4_2_5 omnetpp-inet_4_3_9;
      omnetpp-inet = omnetpp-inet_4_2_5;
    });

    p4-tutorials = lib.makeScope scope.newScope (self: {
      buildPackages = {
        protobuf = pkgs.buildPackages.callPackage ./pkgs/protobuf/3.2.nix { };
      };
      python3 = pkgs.python37;
      protobuf = scope.protobuf3_2;
      grpc = scope.grpc_1_3_2;
      pi = self.callPackage ./pkgs/p4lang/PI/41358da.nix {};
      bmv2 = self.callPackage ./pkgs/p4lang/behavioral-model/b447ac4.nix { };
      p4c = self.callPackage ./pkgs/p4lang/p4c/69e132d0d.nix { };
      mininet = pkgs.mininet.override { python3 = self.python3; };
      shell = 
        let 
          pythonPackages = pkgs.python37Packages.overrideScope (py_self: py_super: {
            protobuf = py_super.protobuf.override { inherit (self) protobuf buildPackages; };
            grpcio = (py_super.grpcio.override { inherit (self) grpc; }).overridePythonAttrs (attrs: {
              inherit (self.grpc) patches;
              GRPC_PYTHON_LDFLAGS = "-lssl";
              propagatedBuildInputs = attrs.propagatedBuildInputs ++ [ py_self.setuptools ];
            });
            pi-python = py_self.toPythonModule self.pi;
          });
          python = pythonPackages.python.withPackages (ps: [
            ps.psutil
            ps.mininet-python
            pythonPackages.pi-python
            pythonPackages.protobuf
            pythonPackages.grpcio
          ]);
        in pkgs.mkShell {
          nativeBuildInputs = [ pkgs.nettools self.mininet python self.bmv2.targets.simple_switch_grpc self.p4c ];
          passthru = {
            inherit python pythonPackages;
          };
        };
    });

    p4-tutorials_pi = p4-tutorials.pi;

    buildArb = self.callPackage ./pkgs/bioinf/arb/buildArb.nix { };
    arbcommon = self.callPackage ./pkgs/bioinf/arb/common { };
    arbcore = self.callPackage ./pkgs/bioinf/arb/core { };
    arbaisc = self.callPackage ./pkgs/bioinf/arb/aisc { };
    arbaisc_com = self.callPackage ./pkgs/bioinf/arb/aisc_com { };
    arbaisc_mkptps = self.callPackage ./pkgs/bioinf/arb/aisc_mkptps { };
    arbdb = self.callPackage ./pkgs/bioinf/arb/db { };
    arbslcb = self.callPackage ./pkgs/bioinf/arb/sl/cb { };
    arbprobe_com = self.callPackage ./pkgs/bioinf/arb/probe_com { };
    arbslhelix = self.callPackage ./pkgs/bioinf/arb/sl/helix { };
    sina = self.callPackage ./pkgs/bioinf/sina { };
    prokka = self.callPackage ./pkgs/bioinf/prokka { };
    infernal = self.callPackage ./pkgs/bioinf/infernal { };
    cd-hit = self.callPackage ./pkgs/bioinf/cd-hit { };

    anyconnect = self.callPackage ./pkgs/anyconnect { };

    inherit (self.callPackage ./pkgs/hadoop { 
      jre = pkgs.jre8;
      maven = pkgs.maven.override { jdk = pkgs.jdk8; };
      stdenv = pkgs.gcc13Stdenv;
    }) hadoop_3_1 hadoop_2_6_5;

    hadoop = hadoop_3_1;

    spark_2_4_4 = self.callPackage ./pkgs/spark/2_4_4.nix {
      jdk = pkgs.jdk8;
      maven = pkgs.maven.override { jdk = pkgs.jdk8; };
      hadoop = self.hadoop_2_6_5;
    };

    intelSGXDCAPPrebuilt1_4 =
      self.callPackage ./pkgs/intel-sgx-dcap-prebuilt/1_4.nix { };

    intelSGXDCAPPrebuilt1_8 =
      self.callPackage ./pkgs/intel-sgx-dcap-prebuilt/1_8.nix { };

    intelSGXPackages_2_7_1 = self.callPackage ./pkgs/intel-sgx/2_7_1.nix {
      stdenv = pkgs.gcc13Stdenv;
      protobuf = self.protobuf3_10;
      intelSGXDCAPPrebuilt = intelSGXDCAPPrebuilt1_8;
      openssl = pkgs.openssl_1_1;
    };

    protobuf3_2 = self.callPackage ./pkgs/protobuf/3.2.nix {};
    protobuf3_6 = self.callPackage ./pkgs/protobuf/3.6.nix {};
    protobuf3_10 = self.callPackage ./pkgs/protobuf/3.10.nix {};
    protobuf2_5 = self.callPackage ./pkgs/protobuf/2.5.nix {};

    intelSGXPackages_2_7_1-debug = intelSGXPackages_2_7_1.override {
          debugMode = true;
    };

    ise = self.callPackage ./pkgs/ise { };

    intelSGXPackages_2_11 = self.callPackage ./pkgs/intel-sgx/2_11.nix {
      intelSGXDCAPPrebuilt = intelSGXDCAPPrebuilt1_8;
    };

    intelSGXPackages = intelSGXPackages_2_11;

    intel-sgx-sdk = intelSGXPackages.sdk;
    intel-sgx-psw = intelSGXPackages.psw;

    intel-sgx-sdk_2_7_1 = intelSGXPackages_2_7_1.sdk;
    intel-sgx-psw_2_7_1 = intelSGXPackages_2_7_1.psw;

    intel-sgx-sdk_2_7_1-debug = intelSGXPackages_2_7_1-debug.sdk;
    intel-sgx-psw_2_7_1-debug = intelSGXPackages_2_7_1-debug.psw;

    intel-sgx-ssl_2_11 = let
      openssl_1_1_1_g = pkgs.openssl.overrideAttrs (attrs: {
        src = pkgs.fetchurl {
          url = "https://www.openssl.org/source/openssl-1.1.1g.tar.gz";
          sha256 = "3bBHdPHjLwxJdR4htnIWrIeFLOsFa3UgmvJENABjbUY=";
        };
      });
    in self.callPackage ./pkgs/intel-sgx-ssl/2_11.nix {
      openssl = openssl_1_1_1_g;
    };

    intel-sgx-ssl_2_5 = let
      openssl_1_1_1_d = pkgs.openssl.overrideAttrs (attrs: {
        src = pkgs.fetchurl {
          url = "https://www.openssl.org/source/openssl-1.1.1d.tar.gz";
          sha256 = "1whinyw402z3b9xlb3qaxv4b9sk4w1bgh9k0y8df1z4x3yy92fhy";
        };
      });
    in self.callPackage ./pkgs/intel-sgx-ssl/2_5.nix {
      openssl = openssl_1_1_1_d;
      intel-sgx-sdk = intelSGXPackages_2_7_1.sdk;
    };

    intel-sgx-ssl = intel-sgx-ssl_2_11;

    mariadbpp = self.callPackage ./pkgs/mariadbpp { };

    splitstree = self.callPackage ./pkgs/bioinf/splitstree {
      openjdk = pkgs.openjdk12 or pkgs.openjdk14;
    };

    abricate = self.callPackage ./pkgs/bioinf/abricate { };

    any2fasta = self.callPackage ./pkgs/bioinf/any2fasta { };

    easyfig = pkgs.python2.pkgs.callPackage ./pkgs/bioinf/easyfig { };

    ncbi_tools = self.callPackage ./pkgs/bioinf/ncbi_tools { };
    aragorn = self.callPackage ./pkgs/bioinf/aragorn { };
    prodigal = self.callPackage ./pkgs/bioinf/prodigal { };

    mafft = self.callPackage ./pkgs/bioinf/mafft { };

    mcl = self.callPackage ./pkgs/bioinf/mcl { };
    prank = self.callPackage ./pkgs/bioinf/prank { };
    FastTree = self.callPackage ./pkgs/bioinf/fasttree { };

    openenclave = 
      let ocamlPackages = pkgs.ocamlPackages_latest;
       in self.callPackage ./pkgs/openenclave {
        inherit (ocamlPackages) ocaml;
        dune = ocamlPackages.dune or ocamlPackages.dune_2;
        stdenv = pkgs.gcc13Stdenv;
        intel-sgx-sdk = intel-sgx-sdk_2_7_1;
        intel-sgx-psw = intel-sgx-psw_2_7_1;
      };

    #opaque = self.callPackage ./pkgs/opaque { 
    #  intel-sgx-sdk = intel-sgx-sdk_2_7_1;
    #  intel-sgx-psw = intel-sgx-psw_2_7_1;
    #};

    perlPackages =
      self.callPackage ./pkgs/perl-packages.nix { inherit (pkgs) perlPackages; }
      // pkgs.perlPackages // {
        recurseForDerivations = false;
      };

    inherit (perlPackages) BioPerl BioRoary BioSearchIOhmmer;

    autofirma = self.callPackage ./pkgs/autofirma { };
    spot = self.callPackage ./pkgs/spot/default.nix {
      autoreconfHook = autoreconfHook269;
      stdenv = pkgs.gcc13Stdenv;
    };
    tchecker = self.callPackage ./pkgs/tchecker { };
    tcltl = self.callPackage ./pkgs/tcltl { 
      autoreconfHook = autoreconfHook269;
    };

    storm_1_2_4 = self.callPackage ./pkgs/storm/1_2_4.nix { jdk = pkgs.jdk8; };
    storm_2_3_0 = self.callPackage ./pkgs/storm/2_3_0.nix { };
    storm = storm_2_3_0;

    zookeeper_3_4_14 = self.callPackage ./pkgs/zookeeper/3_4_14.nix { };

    grpc_1_3_2 = self.callPackage ./pkgs/grpc/1_3_2.nix { protobuf = self.protobuf3_2; };
    grpc_1_17_0 = self.callPackage ./pkgs/grpc/1_17_0.nix { protobuf = pkgs.protobuf3_6; };

    ncmpcpp = self.callPackage ./pkgs/ncmpcpp { };

    scalapbc = self.callPackage ./pkgs/scalapbc { };

    canonPrinterPPD = self.callPackage ./pkgs/canon-printer-ppd { };
    prism = self.callPackage ./pkgs/prism { };
    uppaal = self.callPackage ./pkgs/uppaal { };

    hprotoc = pkgs.haskellPackages.callPackage ./pkgs/hprotoc { };
  } // lib.optionalAttrs (!(pkgs ? buildMavenRepositoryFromLockFile)) mvn2nix);
in scope.packages scope
