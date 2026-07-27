flake: final: prev:
let
  inherit (final) callPackage;
in
let
  cp = f: (callPackage f) { };
in
{
  unstable = flake.lib.mkPkgs {
    nixpkgs = flake.inputs.nixpkgs-unstable;
    inherit (prev) system;
  };
  inherit flake;

  nbr = import "${flake.inputs.nbr}" { pkgs = final // { buildFHSUserEnv = final.buildFHSEnv; }; };

  pythonPackagesExtensions = [
    (final: prev: {
    })
  ];

  python3PackagesBin = prev.python3Packages.overrideScope (
    self: super: {
      torch = super.pytorch-bin;
      # torch = super.torch-bin // {
      #   inherit (super.torch) cudaCapabilities cxxdev;
      #   cudaSupport = true;
      # };
      torchaudio = super.torchaudio-bin;
      torchvision = super.torchvision-bin;
    }
  );

  enroot = callPackage ./pkgs/enroot.nix {};

  python3PackagesCuda = prev.python3Packages.overrideScope (self: super: {
    cudaSupport = true;
    ctranslate2 = super.ctranslate2.override {
      ctranslate2-cpp = prev.ctranslate2.override {
        withCUDA = true;
        withCuDNN = true;  
      };
    };
  });

  lib = prev.lib.extend (
    final: prev: {
      jpg2png = cp ./lib/jpg2png.nix;
      buildDockerEnv = cp ./lib/buildDockerEnv.nix;
    }
  );

  plymouthSvgLogo = cp ./pkgs/plymouthSvgLogo.nix;

  buildFHSUserEnv = prev.buildFHSEnv;

  personal-utils = cp ./pkgs/personal-utils.nix;
  fhsctl = cp ./pkgs/fhsctl.nix;
  pkg = cp ./pkgs/pkg.nix;
  text2image = cp ./pkgs/text2image.nix;
  wrapWine = cp ./pkgs/wrapWine.nix;

  prev = prev;

  nomad-driver-nvidia =  prev.buildGoModule rec {
    pname = "nomad-driver-nvidia";
    version = "1.1.0";

    src = prev.fetchFromGitHub {
      owner = "hashicorp";
      repo = "nomad-device-nvidia";
      tag = "v${version}";
      hash = "sha256-vjLI/WkeKEM8Gbt/P8cilyZ2A9oNOyqDRw0v6kp3D1M=";
    };
    vendorHash = "sha256-m5aF0pAmh1OnfJrgGHInLrQ9pCU/PasO4BrWfKzk8Ug=";

    postFixup = ''
      mkdir -p $out/libexec
      mv $out/bin/cmd $out/libexec/nomad-device-nvidia
      makeWrapper $out/libexec/nomad-device-nvidia $out/bin/nomad-device-nvidia \
        --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib \
        --prefix LD_PRELOAD : /run/opengl-driver/lib/libnvidia-ml.so \
        --prefix PATH : /run/current-system/sw/bin
    '';

    env.CGO_ENABLED = 1;

    nativeBuildInputs = [ prev.autoAddDriverRunpath prev.makeWrapper ];

    doCheck = false;
  };
  nur = import flake.inputs.nur { pkgs = prev; };

  custom = rec {
    kodi = final.kodi.withPackages (
      kpkgs: with kpkgs; [
        vfs-sftp
        sponsorblock
        joystick
        sendtokodi
      ]
    );
    colorpipe = cp ./pkgs/colorpipe;
    ncdu = cp ./pkgs/custom/ncdu.nix;
    neovim = cp ./pkgs/custom/neovim;
    emacs = cp ./pkgs/custom/emacs;
    firefox = cp ./pkgs/custom/firefox;
    tixati = cp ./pkgs/custom/tixati.nix;
    pidgin = cp ./pkgs/custom/pidgin.nix;
    send2kindle = cp ./pkgs/custom/send2kindle.nix;
    retroarch = cp ./pkgs/custom/retroarch.nix;
    polybar = cp ./pkgs/custom/polybar.nix;
    colors-lib-contrib = import "${flake.inputs.nix-colors}/lib/contrib" { pkgs = prev; };
    # wallpaper = ./wall.jpg;
    wallpaper = colors-lib-contrib.nixWallpaperFromScheme {
      scheme = final.custom.colors;
      width = 1366;
      height = 768;
      logoScale = 2;
    };
    inherit (flake) colors;
  };

  script-directory-wrapper = final.writeShellScriptBin "sdw" ''
    set -eu
    export SD_CMD=
    export SD_ROOT="$(${flake}/bin/source_me sd d root)"
    [ -d "$SD_ROOT" ]
    "$SD_ROOT/bin/source_me" sd "$@"
  '';

  opencv4Full = prev.python3Packages.opencv4.override {
    pythonPackages = prev.python3Packages;
    enablePython = true;
    enableContrib = true;
    enableTesseract = true;
    enableOvis = true;
    enableUnfree = true;
    enableGtk3 = true;
    enableGPhoto2 = true;
    enableFfmpeg = true;
    enableGStreamer = false;
    enableIpp = true;
    enableTbb = true;
    enableDC1394 = true;
  };

  opencv4FullCuda = final.opencv4Full.override {
    enableCuda = true;
    enableCudnn = true;
  };

  intel-ocl = prev.intel-ocl.overrideAttrs (old: {
    src = prev.fetchzip {
      url = "https://github.com/lucasew/nixcfg/releases/download/debureaucracyzzz/SRB5.0_linux64.zip";
      sha256 = "sha256-4qaX7wTqxKSrRWeQv1Zrs6eTT0fKJ6g9QBFocugwd2E=";
      stripRoot = false;
    };
  });

  elixir_edge = final.unstable.elixir.override { erlang = final.unstable.erlang_27; };
}
