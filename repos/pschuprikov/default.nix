{ pkgs ? import <nixpkgs> { } }:
let
  autoreconfHook269 = if pkgs ? autoreconfHook269 then
    pkgs.autoreconfHook269
  else
    pkgs.autoreconfHook;

  scope = pkgs.lib.makeScope pkgs.newScope (self: rec {
    # The `lib`, `modules`, and `overlay` names are special
    lib = pkgs.lib // import ./lib { inherit pkgs; }; # functions
    modules = import ./modules; # NixOS modules
    overlays = import ./overlays; # nixpkgs overlays

    otcl = self.callPackage ./pkgs/otcl { };
    tclcl = self.callPackage ./pkgs/tclcl { };
    ns-2 = self.callPackage ./pkgs/ns2 { };
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
    compdb = pkgs.python3Packages.callPackage ./pkgs/compdb { };

    blast = pkgs.blast.override { stdenv = pkgs.gcc9Stdenv; };

    #hadoop = (self.callPackage ./pkgs/hadoop { 
    #  jre = pkgs.jre8;
    #  maven = pkgs.maven.override { jdk = pkgs.jdk8; };
    #}).hadoop_3_1;

    intelSGXDCAPPrebuilt1_4 =
      self.callPackage ./pkgs/intel-sgx-dcap-prebuilt/1_4.nix { };

    intelSGXDCAPPrebuilt1_8 =
      self.callPackage ./pkgs/intel-sgx-dcap-prebuilt/1_8.nix { };

    intelSGXPackages_2_7_1 = self.callPackage ./pkgs/intel-sgx/2_7_1.nix {
      protobuf = pkgs.protobuf3_10;
      intelSGXDCAPPrebuilt = intelSGXDCAPPrebuilt1_8;
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

    easyfig =
      pkgs.pythonPackages.callPackage ./pkgs/bioinf/easyfig { inherit blast; };

    ncbi_tools = self.callPackage ./pkgs/bioinf/ncbi_tools { };
    aragorn = self.callPackage ./pkgs/bioinf/aragorn { };
    prodigal = self.callPackage ./pkgs/bioinf/prodigal { };

    mafft = self.callPackage ./pkgs/bioinf/mafft { };

    mcl = self.callPackage ./pkgs/bioinf/mcl { };
    prank = self.callPackage ./pkgs/bioinf/prank { };
    FastTree = self.callPackage ./pkgs/bioinf/fasttree { };
    markdown2ctags = pkgs.python3Packages.callPackage ./pkgs/markdown2ctags { };

    openenclave = 
      let ocamlPackages = pkgs.ocamlPackages_latest;
       in self.callPackage ./pkgs/openenclave {
        inherit (ocamlPackages) ocaml;
        dune = ocamlPackages.dune or ocamlPackages.dune_2;
        stdenv = pkgs.gcc9Stdenv;
        intel-sgx-sdk = intel-sgx-sdk_2_7_1;
        intel-sgx-psw = intel-sgx-psw_2_7_1;
      };

    #opaque = self.callPackage ./pkgs/opaque { 
    #  intel-sgx-sdk = intel-sgx-sdk_2_7_1;
    #  intel-sgx-psw = intel-sgx-psw_2_7_1;
    #};

    llvmPackagesWithGcc10 = let
      gccForLibs = pkgs.gcc10.cc;
      wrapCCWith = args: pkgs.wrapCCWith (args // { inherit gccForLibs; });
      llvmPackages = pkgs.llvmPackages_10.override {
        buildLlvmTools = llvmPackages.tools;
        targetLlvmLibraries = llvmPackages.libraries;
        inherit wrapCCWith gccForLibs;
      };
    in llvmPackages;

    perlPackages =
      self.callPackage ./pkgs/perl-packages.nix { inherit (pkgs) perlPackages; }
      // pkgs.perlPackages // {
        recurseForDerivations = false;
      };

    inherit (perlPackages) BioPerl BioRoary BioSearchIOhmmer;

    autofirma = self.callPackage ./pkgs/autofirma { };
    spot = self.callPackage ./pkgs/spot/default.nix {
      autoreconfHook = autoreconfHook269;
    };
    tchecker = self.callPackage ./pkgs/tchecker { };
    tcltl = self.callPackage ./pkgs/tcltl { 
      autoreconfHook = autoreconfHook269;
    };

    ncmpcpp = self.callPackage ./pkgs/ncmpcpp { };
  });
in scope.packages scope
