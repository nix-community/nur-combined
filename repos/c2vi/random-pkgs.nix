{ mypkgs, specialArgs, nixos-generators,
  system, inputs, nixpkgs, self,
  ... 
}: let
  pkgs = import nixpkgs { inherit system; };
in rec {


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

    #zephyrDepsHash = "sha256-n7xX/d8RLqDyPOX4AEo5hl/3tQtY6mZ6s8emYYtOYOg=";
    zephyrDepsHash = "sha256-/ECQR3x0hzVGB7icGuWeyyNC9HuWmCgS5xA8r30gCAw=";
  };


  keyboardLeft = inputs.zmk-nix.legacyPackages.${system}.buildKeyboard {
    name = "firmware-left";

    src = ./zmk-config;

    board = "nice_nano_v2";

    # the charybdis has a left and right, so the default parts works
    shield = "charybdis_left";

    #zephyrDepsHash = "sha256-n7xX/d8RLqDyPOX4AEo5hl/3tQtY6mZ6s8emYYtOYOg=";
    zephyrDepsHash = "sha256-/ECQR3x0hzVGB7icGuWeyyNC9HuWmCgS5xA8r30gCAw=";
  };



  keyboardBoth = inputs.zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
    name = "firmware";

    src = ./zmk-config;

    board = "nice_nano_v2";

    # the charybdis has a left and right, so the default parts works
    shield = "charybdis_%PART%";

    #zephyrDepsHash = "sha256-n7xX/d8RLqDyPOX4AEo5hl/3tQtY6mZ6s8emYYtOYOg=";
    zephyrDepsHash = "sha256-/ECQR3x0hzVGB7icGuWeyyNC9HuWmCgS5xA8r30gCAw=";
  };



  unkillableKernelModule = mypkgs.callPackage ./mods/unkillable-process-kernel-module.nix {
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
    ${self.nixosConfigurations.hpm.config.system.build.vm}/bin/run-hpm-vm -m 4G -cpu host -smp 4
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
