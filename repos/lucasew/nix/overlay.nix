flake: final: prev:
let
  inherit (flake.outputs) global;
  inherit (final) callPackage;
  inherit (prev) lib writeShellScript;
  inherit (lib) recursiveUpdate;
  inherit (builtins)
    toString
    length
    head
    tail
    ;
in
let
  cp = f: (callPackage f) { };
in
{
  inherit flake;
  bumpkin = rec {
    bumpkin = cp flake.inputs.bumpkin;
    inputs = bumpkin.loadBumpkin {
      inputFile = ../bumpkin.json;
      outputFile = ../bumpkin.json.lock;
    };
    unpacked = (cp ./lib/unpackRecursive.nix) inputs;
  };

  nbr = import "${flake.inputs.nbr}" { pkgs = final; };

  pythonPackagesExtensions = [
    (final: prev: {
      std2 = prev.std2.overrideAttrs (old: {
        src = flake.inputs.src-python-std2;
      });
      pynvim_pp = prev.pynvim_pp.overrideAttrs (old: {
        src = flake.inputs.src-python-pynvim_pp;
      });
      rtfunicode = final.callPackage ./pkgs/python/rtfunicode { };
      pyctcdecode = final.callPackage ./pkgs/python/pyctcdecode { };
      kenlm = final.callPackage ./pkgs/python/kenlm { };
      facenet-pytorch = final.callPackage ./pkgs/python/facenet-pytorch { };
      face_recognition = prev.face_recognition.overrideAttrs (old: {
        dontUsePytestCheck = true;
        dontUseSetuptoolsCheck = true;
        # dontCheck = true;
        # doCheck = false;
      });
      dlib = prev.dlib.overrideAttrs (old: {
        dontUsePytestCheck = true;
        openblas = prev.pkgs.blas;
        postPatch = ''
          ${old.postPatch or ""}
          rm -rf tools/python/test/*
          printf "def test_dummy():\n\tassert True\n" > tools/python/test/test_dummy.py
        '';
      });
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

  python3PackagesCuda = prev.python3Packages.overrideScope (_: _: { cudaSupport = true; });

  lib = prev.lib.extend (
    final: prev: {
      jpg2png = cp ./lib/jpg2png.nix;
      buildDockerEnv = cp ./lib/buildDockerEnv.nix;
      climod = cp flake.inputs.climod;
    }
  );

  bin = builtins.mapAttrs (
    k: v:
    final.stdenvNoCC.mkDerivation {
      name = k;
      dontUnpack = true;

      nativeBuildInputs = [ final.makeWrapper ];

      installPhase = ''
        mkdir $out/bin -p
        install -m 755 ${../bin}/${k} $out/bin/${k}
        wrapProgram $out/bin/${k} \
          --set NIX_PATH nixpkgs=${final.path}:nixpkgs-overlays=${flake.outPath}/nix/compat/overlay.nix:home-manager=${flake.inputs.home-manager}:nur=${flake.inputs.nur}
      '';
      meta.mainProgram = k;
    }
  ) (builtins.readDir ../bin);

  devenv = final.writeShellScriptBin "devenv" ''
    nix run ${flake.inputs.devenv}# -- "$@"
  '';

  ctl = cp ./pkgs/ctl;
  cmdlinegl = cp ./pkgs/cmdlinegl;

  personal-utils = cp ./pkgs/personal-utils.nix;
  fhsctl = cp ./pkgs/fhsctl.nix;
  comby = cp ./pkgs/comby.nix;
  pkg = cp ./pkgs/pkg.nix;
  text2image = cp ./pkgs/text2image.nix;
  wrapWine = cp ./pkgs/wrapWine.nix;
  ollama-webui = cp ./pkgs/ollama-webui;
  home-manager = cp "${flake.inputs.home-manager}/home-manager";

  prev = prev;
  requireFileSources = [ flake.inputs.nix-requirefile-data ];

  appimage-wrap = final.nbr.appimage-wrap;

  dotenv = cp flake.inputs.dotenv;
  p2k = cp flake.inputs.pocket2kindle;
  pytorrentsearch = cp flake.inputs.pytorrentsearch;
  redial_proxy = cp flake.inputs.redial_proxy;
  send2kindle = cp flake.inputs.send2kindle;
  nixgram = cp flake.inputs.nixgram;
  go-annotation = cp flake.inputs.go-annotation;
  ts-proxy = cp flake.inputs.ts-proxy;
  wrapVSCode = args: import flake.inputs.nix-vscode (args // { pkgs = prev; });
  wrapEmacs = args: import flake.inputs.nix-emacs (args // { pkgs = prev; });

  instantngp = cp ./pkgs/instantngp.nix;

  # nix-option = callPackage "${flake.inputs.nix-option}" {
  #   nixos-option = (callPackage "${flake.inputs.nixpkgs}/nixos/modules/installer/tools/nixos-option" { }).overrideAttrs (attrs: attrs // {
  #     meta = attrs.meta // {
  #       platforms = lib.platforms.all;
  #     };
  #   });
  # };
  nur = import flake.inputs.nur { pkgs = prev; };

  pulseaudio-module-xrdp = cp ./pkgs/pulseaudio-module-xrdp.nix;

  wineApps = {
    cs_extreme = cp ./pkgs/wineApps/cs_extreme.nix;
    dead_space = cp ./pkgs/wineApps/dead_space.nix;
    gta_sa = cp ./pkgs/wineApps/gta_sa.nix;
    among_us = cp ./pkgs/wineApps/among_us.nix;
    ets2 = cp ./pkgs/wineApps/ets2.nix;
    mspaint = cp ./pkgs/wineApps/mspaint.nix;
    pinball = cp ./pkgs/wineApps/pinball.nix;
    sosim = cp ./pkgs/wineApps/sosim.nix;
    tora = cp ./pkgs/wineApps/tora.nix;
    nfsu2 = cp ./pkgs/wineApps/nfsu2.nix;
    flatout2 = cp ./pkgs/wineApps/flatout2.nix;
    watchdogs2 = cp ./pkgs/wineApps/watchdogs2.nix;
    rimworld = cp ./pkgs/wineApps/rimworld.nix;
    skyrim = cp ./pkgs/wineApps/skyrim.nix;
  };
  custom = rec {
    colorpipe = cp ./pkgs/colorpipe;
    chromium = cp ./pkgs/custom/chromium;
    ncdu = cp ./pkgs/custom/ncdu.nix;
    neovim = cp ./pkgs/custom/neovim;
    emacs = cp ./pkgs/custom/emacs;
    firefox = cp ./pkgs/custom/firefox;
    tixati = cp ./pkgs/custom/tixati.nix;
    vscode = cp ./pkgs/custom/vscode;
    rofi = cp ./pkgs/custom/rofi.nix;
    pidgin = cp ./pkgs/custom/pidgin.nix;
    send2kindle = cp ./pkgs/custom/send2kindle.nix;
    retroarch = cp ./pkgs/custom/retroarch.nix;
    loader = cp ./pkgs/custom/loader/default.nix;
    polybar = cp ./pkgs/custom/polybar.nix;
    colors-lib-contrib = import "${flake.inputs.nix-colors}/lib/contrib" { pkgs = prev; };
    # wallpaper = ./wall.jpg;
    wallpaper = colors-lib-contrib.nixWallpaperFromScheme {
      scheme = colors;
      width = 1366;
      height = 768;
      logoScale = 2;
    };
    inherit (flake.outputs) colors;
  };

  script-directory = prev.script-directory.overrideAttrs (old: {
    postInstall =
      (old.postInstall or "")
      + ''
        installShellCompletion --bash ${
          prev.fetchurl {
            name = "sd";
            url = "https://raw.githubusercontent.com/lucasew/sd/7ae91cca81a69eae8a37b001b4b07b088e2c49fa/_sd.bash";
            hash = "sha256-BVFpec814CmbjFvZ++U4RR+6gTv9x4ojFgAYzJp0rQs=";
          }
        }
      '';
  });

  script-directory-wrapper = final.writeShellScriptBin "sdw" ''
    PATH=$PATH:${final.script-directory}/bin:${final.bash}/bin
    export SD_ROOT="$(SD_ROOT=${../bin} sd d root)/bin"
    sd "$@"
  '';

  ccacheWrapper = prev.ccacheWrapper.override {
    extraConfig = ''
      export CCACHE_COMPRESS=1
      export CCACHE_DIR="/var/cache/ccache"
      export CCACHE_UMASK=007
      if [ ! -d "$CCACHE_DIR" ]; then
        echo "====="
        echo "Directory '$CCACHE_DIR' does not exist"
        echo "Please create it with:"
        echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
        echo "  sudo chown root:nixbld '$CCACHE_DIR'"
        echo "====="
        exit 1
      fi
      if [ ! -w "$CCACHE_DIR" ]; then
        echo "====="
        echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
        echo "Please verify its access permissions"
        echo "====="
        exit 1
      fi
    '';
  };

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

  mopidyPackages = prev.mopidyPackages.overrideScope (
    self: super: {
      mopidy-ytmusic = super.mopidy-ytmusic.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ super.pythonPackages.pythonRelaxDepsHook ];
        pythonRelaxDeps = [
          "ytmusicapi"
          "pytube"
        ];
      });
    }
  );

  cached-nix-shell = callPackage flake.inputs.src-cached-nix-shell { pkgs = prev; };

  ollama-cuda = prev.ollama.override { acceleration = "cuda"; };
  ollama-rocm = prev.ollama.override { acceleration = "rocm"; };

  rio = flake.inputs.rio.packages.${prev.system}.default;

  arcan = prev.arcan.override { useTracy = false; };

  regex101 = prev.callPackage flake.inputs.regex101 { };

  # nix = prev.nixVersions.nix_2_15;
  # electron = prev.electron_27-bin;
  # electron_25 = prev.electron_25-bin;
}
