pkgs: pkgsSuper:
let
  inherit (pkgs) callPackage lib;

  ulypkgsPackages = {

    ### Meta

    inherit ulypkgsPackages;

    ulypkgsPackagesDerivationsOnly = lib.filterAttrs (attr: package: lib.isDerivation package) (
      removeAttrs ulypkgsPackages [ "ulypkgsPackagesDerivationsOnly" ] # avoid infrec
    );

    listing = callPackage ./listing { };

    update = callPackage ./update { };

    ### Build support

    # postInstall
    copyIcons = callPackage ./copyIcons { };

    # preInstall
    copyInstallHook = callPackage ./copyInstallHook { };

    # preFixup (useless files) & postFixup (empty dirs)
    deleteUselessFiles = callPackage ./deleteUselessFiles { };

    fetchGoogleDrive = callPackage ./fetchGoogleDrive { };

    fetchMediaFire = callPackage ./fetchMediaFire { };

    fetchMega = callPackage ./fetchMega { };

    fetchWebIcon = callPackage ./fetchWebIcon { };

    genericUnpackHook = callPackage ./genericUnpackHook { };

    godotWrapHook = callPackage ./godotWrapHook { };
    godot3WrapHook = pkgs.godotWrapHook.override {
      targetPackages = pkgs.targetPackages // {
        godot = pkgs.godot3;
      };
    };
    godot43WrapHook = pkgs.godotWrapHook.override {
      targetPackages = pkgs.targetPackages // {
        inherit (pkgs.godotPackages_4_3) godot;
      };
    };

    # buildPhase
    renpyBuildHook = callPackage ./renpyBuildHook { };
    renpy7BuildHook = pkgs.renpyBuildHook.override { renpy = pkgs.renpy_7; };

    # postFixup
    renpyPackHook = callPackage ./renpyPackHook { };

    # postUnpack
    renpyUnpackHook = callPackage ./renpyUnpackHook { };

    # postInstall & preFixup (delete executables)
    renpyWrapHook = callPackage ./renpyWrapHook { };
    renpy7WrapHook = pkgs.renpyWrapHook.override {
      targetPackages = pkgs.targetPackages // {
        renpy = pkgs.targetPackages.renpy_7;
      };
    };

    # postInstall
    resizeIcons = callPackage ./resizeIcons { };

    # postInstall & preFixup (delete executables)
    rpgNwjsWrapHook = callPackage ./rpgNwjsWrapHook { };

    # postBuild
    shrinkAssets = callPackage ./shrinkAssets { };

    ### Development

    python2 =
      (pkgsSuper.python2.override {
        self = ulypkgsPackages.python2;
        packageOverrides = import ./python2/packages.nix;
      }).overrideAttrs
        (attrsSuper: {
          meta = attrsSuper.meta // {
            mainProgram = "python";
          };
        });
    python2Packages = ulypkgsPackages.python2.pkgs;

    renpy_7 = callPackage ./renpy_7 { };

    ### Applications

    # testing purpose
    hello = pkgsSuper.hello.overrideAttrs (attrsSuper: {
      postPatch = ''
        ${attrsSuper.postPatch or ""}
        substituteInPlace src/hello.c tests/{hello,traditional}-1 --replace-fail world ulypkgs
      '';
    });

    # https://github.com/NixOS/nixpkgs/pull/507156
    patreon-downloader = callPackage ./patreon-downloader { };

    playwright-scrape = callPackage ./playwright-scrape { };

    ### Games

    eternum = callPackage ./eternum { };

    evermore = callPackage ./evermore { };

    katawa-shoujo = callPackage ./katawa-shoujo { };

    legbreaker = callPackage ./legbreaker { };

    once-in-a-lifetime = callPackage ./once-in-a-lifetime { };

    oppai-oppai-orbs = callPackage ./oppai-oppai-orbs { };

    summertime-saga = callPackage ./summertime-saga { };
  };

  unexported = {
    pythonPackagesExtensions = pkgsSuper.pythonPackagesExtensions ++ [ (import ./python/packages.nix) ];
  };
in
ulypkgsPackages // unexported
