{ mypkgs, specialArgs, nixos-generators,
  system, inputs, nixpkgs, self, nixpkgs-unstable,
  ... 
}: let
  pkgs = import nixpkgs { inherit system; };
  pkgsUnstable = import nixpkgs-unstable { inherit system; };
  lib = pkgs.lib;
in rec {
  
  affine = (pkgs.affine.overrideAttrs {
    patches = [
      "../overlays/patches/affin-edgeless-right-click-drag.patch"
    ];
  });
  

  runc = pkgs.runc.overrideAttrs ({
    src = /home/me/work/config/gitignore/runc;
  });

  qtrs = pkgs.stdenv.mkDerivation {
    name = "qt rust bindings";

    nativeBuildInputs = with pkgs; [
      openssl
      pkg-config
      sqlite
      
      #clang
      #libclang.dev
      #libclang
      #libclang.lib
      cargo
      libsForQt5.qt5.full
    ];

    LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
    RITUAL_STD_HEADERS = "${pkgs.libcxx.dev}/include/c++/v1";

    buildInputs = with pkgs; [
      libclang.dev
      libclang.lib
      sqlite
      libsForQt5.qt5.full
    ];

    dontUnpack = true;
    dontPatch = true;
    buildPhase = ''
      cargo test
    '';

  };

  resolve = pkgs.davinci-resolve.overrideAttrs (prev: {
    extraBwrapArgs = prev.extraBwrapArgs or [] ++ [
      "--bind /etc/OpenCL /etc/OpenCL"
    ];
  });

  tmp-resolve = pkgs.stdenv.mkDerivation {
    name = "my-test-env";
    nativeBuildInputs = with pkgs; [ intel-compute-runtime-legacy1 pkg-config ];
    buildInputs = with pkgs; [ intel-compute-runtime-legacy1 ];
  };

  sunshine = pkgsUnstable.sunshine.overrideAttrs (prev: {
    patches = prev.patches or [] ++ [
      #(pkgs.fetchpatch {
        #url = "https://github.com/LizardByte/Sunshine/pull/2507.patch";
        #hash = "sha256-DdyiR7djH4GF1bcQP/a20BYpTBvrAzd0UxJ0o0nC4rU=";
      #})
    ];

    buildInputs = prev.buildInputs or [] ++ [
      pkgsUnstable.pipewire
      pkgsUnstable.xdg-desktop-portal
    ];
    cmakeFlage = prev.cmakeFlags or [] ++ [
      (lib.cmakeBool "SUNSHINE_ENABLE_PORTAL" true)
    ];

    src = pkgs.fetchFromGitHub {
      #owner = "LizardByte";
      owner = "c2vi";
      repo = "Sunshine";
      rev = "2671cd374dc5d12d402de572d170c9dfee8c5d7b";
      hash = "sha256-7IOMXmvl7/WYF6ktSUrLZjq+Lnq9YpSqUsj0FVtG8tI=";
      fetchSubmodules = true;
    };
  });

  #######################################################################
  # make an iso
  #to build:  nix build .#random.iso.config.system.build.isoImage

  # an old old nixpkgs: https://github.com/NixOS/nixpkgs/tree/release-15.09
  iso = let
    oldNixpkgsSrc = pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "cc7c26173149348ba43f0799fac3f3823a2d21fc"; # 15.09
      #rev = "3ba3d8d8cbec36605095d3a30ff6b82902af289c";
      #rev = "71db8c7a02f3be7cb49b495786050ce1913246d3";
      hash = "sha256-Bu0ECsynGNuj4lYK/QcvuKqKCKd6b1j8jlE7fLjE+t0=";
    };
    oldPkgs = import oldNixpkgsSrc { system = "x86_64-linux"; };

    # ${nixpkgs-repo}/nixos/default.nix holds a function, that takes a system and a configuration and outputs just what nixpkgs.lib.nixosSystem outputs
    # so we can make our own nixosSystem func
    oldNixosSystem = { system, modules, ... }: import (oldNixpkgsSrc + "/nixos") {
      inherit system;
      configuration = { imports = modules; };
    };



    system = oldNixosSystem {
      system = "x86_64-linux";
      modules = [
        (oldNixpkgsSrc + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
        ({ pkgs, ...}: {
          boot.initrd.kernelModules = [ "fbcon" ];
          services.openssh.enable = true;
          users.users.root.password = "changeme";

          services.xserver.enable = false;
          #services.displayManager.enable = false;
        })
      ];
    };
  in system.config.system.build.isoImage;



  obs = let
    pkgs = import inputs.nixpkgs-unstable { inherit system; };
  in pkgs.wrapOBS {
    plugins = with pkgs.obs-studio-plugins; [
      obs-ndi
    ];
  };



  zephyr = inputs.zephyr-nix.packages.${system};


  one = inputs.zephyr-nix;


  two-shell = pkgs.mkShell {
    packages = with pkgs; [
      (zephyr.sdk.override {
        targets = [
          "arm-zephyr-eabi"
          "x86_64-zephyr-elf"
        ];
      })
      zephyr.pythonEnv
      zephyr.hosttools-nix
      cmake
      ninja
    ];

    shellHook = ''
      echo hiiiiiiiiiiiiiiiii
      export ZEPHYR_BASE=${inputs.zephyr-nix.inputs.zephyr};
    '';
  };


  three = inputs.zmk-nix.legacyPackages.${system}.fetchZephyrDeps {
    name = "testing-deps";
    hash = "";
    src = self;
  };


  four = inputs.zephyr-nix.packages.${system}.buildZephyrWorkspace;


  keyboardRight = inputs.zmk-nix.legacyPackages.${system}.buildKeyboard {
    name = "firmware-right";

    src = ./zmk-config;

    board = "nice_nano_v2";

    # the charybdis has a left and right, so the default parts works
    shield = "charybdis_right";

    postPatch = ''
      mkdir -p ./zmk/app/boards/
      cp -r ./boards/* ./zmk/app/boards/
    '';

    zephyrDepsHash = "sha256-4enAzZRvlV0ni1+rv7PUsRI6Rhb+zweuFBLeb/sflBc=";
  };


  keyboardLeft = inputs.zmk-nix.legacyPackages.${system}.buildKeyboard {
    name = "firmware-left";

    src = ./zmk-config;

    board = "nice_nano_v2";

    # the charybdis has a left and right, so the default parts works
    shield = "charybdis_left";

    postPatch = ''
      mkdir -p ./zmk/app/boards/
      cp -r ./boards/* ./zmk/app/boards/
    '';

    #zephyrDepsHash = "sha256-n7xX/d8RLqDyPOX4AEo5hl/3tQtY6mZ6s8emYYtOYOg=";
    zephyrDepsHash = "sha256-4enAzZRvlV0ni1+rv7PUsRI6Rhb+zweuFBLeb/sflBc=";
  };



  keyboardBoth = inputs.zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
    name = "firmware";

    src = ./zmk-config;

    board = "nice_nano_v2";

    # the charybdis has a left and right, so the default parts works
    shield = "charybdis_%PART%";

    #zephyrDepsHash = "sha256-n7xX/d8RLqDyPOX4AEo5hl/3tQtY6mZ6s8emYYtOYOg=";
    zephyrDepsHash = "sha256-r4SIPCLqBT/y2bblHUUZtNRwrhXFWY8wWtkplbG3coo=";
  };

  
  yt-block = pkgs.callPackage ./scripts/yt-block/app.nix {};


  unkillableKernelModule = mypkgs.callPackage ./scripts/yt-block/unkillable-process-kernel-module.nix {
    kernel = self.nixosConfigurations.main.config.boot.kernelPackages.kernel;
  };

  usbip-kernel = self.nixosConfigurations.main.config.system.build.kernel.overrideAttrs (prev: {
    kernelPatches = prev.kernelPatches or [] ++ [ {
      name = "usbip";
      patch = "null";
      extraConfig = ''
        USB_ACM y
        USBIP_CORE y
        USBIP_VHCI_HCD y
        USBIP_VHCI_HC PORTS 8
        USBIP_VHCI_NR_HCS 1
        USBIP_DEBUG y
        USBIP_SERIAL y
      '';
      } ];
  });

  kernel-test = (nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
		inherit specialArgs;
    modules = [
      ./hosts/main.nix
      ./hardware/hpm-laptop.nix
      #self.nixosConfigurations.main._module
      {
        boot.kernelPatches = [ {
          name = "usbip";
          patch = null;
          extraConfig = ''
            USB_ACM m
            USBIP_CORE m
            USBIP_VHCI_HCD m
            USBIP_VHCI_NR_HCS 1
          '';
            #USBIP_VHCI_HC PORTS 8
            #USBIP_DEBUG y
            #USBIP_SERIAL y
          } ];
      }
    ];
  }).config.system.build.kernel;

  tunefox = mypkgs.firefox-unwrapped.overrideAttrs (final: prev: {
    NIX_CFLAGS_COMPILE = [ (prev.NIX_CFLAGS_COMPILE or "") ] ++ [ "-O3" "-march=native" "-fPIC" ];
    requireSigning = false;
  });

  run-vm = specialArgs.pkgs.writeScriptBin "run-vm" ''
    ${self.nixosConfigurations.main.config.system.build.vm}/bin/run-main-vm -m 4G -cpu host -smp 4
  '';

  hec-img = nixos-generators.nixosGenerate {
    inherit system;
    modules = [
      ./hosts/hpm.nix
    ];
    format = "raw";
    inherit specialArgs;
  };

  prootTermux = inputs.nix-on-droid.outputs.packages.${system}.prootTermux;

  hello-container = let pkgs = nixpkgs.legacyPackages.${system}.pkgs; in pkgs.dockerTools.buildImage {
    name = "hello";
    tag = "0.1.0";

    config = { Cmd = [ "${pkgs.bash}/bin/bash" ]; };

    created = "now";
  };

  kotlin-native = let
    lib = pkgs.lib;
    stdenv = pkgs.stdenv;
    fetchurl = pkgs.fetchurl;
    jre = pkgs.jre;
    makeWrapper = pkgs.makeWrapper;
  in stdenv.mkDerivation rec {
    pname = "kotlin-native";
    version = "2.0.0";

    src = let
      getArch = {
        "aarch64-darwin" = "macos-aarch64";
        "x86_64-darwin" = "macos-x86_64";
        "x86_64-linux" = "linux-x86_64";
      }.${stdenv.system} or (throw "${pname}-${version}: ${stdenv.system} is unsupported.");

      getUrl = version: arch:
        "https://github.com/JetBrains/kotlin/releases/download/v${version}/kotlin-native-prebuilt-${arch}-${version}.tar.gz";

      getHash = arch: {
        "macos-aarch64" = "sha256-PxPQ9tVNyufoqKAR9fcXBtQzn6MkbVI11Sow2O3Tl5A=";
        "macos-x86_64" = "sha256-I+OQqi/ISomh4GtSnJ4sP37NMu9wayXLfb91uJRvh4Q=";
        "linux-x86_64" = "sha256-aVEp0NkKsDQlqtqAygKd3EG/B2PLmZTzCrIrCENXoYk=";
      }.${arch};
    in
      fetchurl {
        url = getUrl version getArch;
        sha256 = getHash getArch;
      };

    nativeBuildInputs = [
      jre
      makeWrapper
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      mv * $out

      runHook postInstall
    '';

    postFixup = ''
      wrapProgram $out/bin/run_konan --prefix PATH ":" ${lib.makeBinPath [ jre ]}
    '';

    meta = {
      homepage = "https://kotlinlang.org/";
      description = "Modern programming language that makes developers happier";
      longDescription = ''
        Kotlin/Native is a technology for compiling Kotlin code to native
        binaries, which can run without a virtual machine. It is an LLVM based
        backend for the Kotlin compiler and native implementation of the Kotlin
        standard library.
      '';
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [ fabianhjr ];
      platforms = [ "x86_64-linux" ] ++ lib.platforms.darwin;
    };
  };
}
