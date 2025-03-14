{
  system ? builtins.currentSystem,
  pkgs ?
    import <nixpkgs> {
      inherit system;
      overlays = import ./overlays.nix;
    },
}: let
  aliases = {
    autorestic = throw "Use `pkgs.autorestic` instead";
    datalad = throw "Use `pkgs.datalad` instead";
    warpd = throw "Use `pkgs.warpd` instead";
    taskwarrior3 = throw "Use `pkgs.taskwarrior` instead";
    "1fps" = throw "Use `pkgs._1fps` instead";
    puffin = throw "Use `pkgs.puffin` instead";
    math-preview = throw "Use `pkgs.math-preview` instead";
    activitywatch-bin = throw "Use `pkgs.activitywatch` instead";
    daqp-python = throw "Use `pkgs.python3Packages.daqp` instead";
    drawille = throw "Use `pkgs.python3Packages.drawille` instead";
    drawilleplot = throw "Use `pkgs.python3Packages.drawilleplot` instead";
    hledger-utils = throw "Use `pkgs.hledger-utils` instead";
    normcap = throw "Use `pkgs.normcap` instead";
    qpsolvers = throw "Use `pkgs.python3Packages.qpsolvers` instead";
    questdb = throw "Use `pkgs.questdb` instead";
  };
  packages = rec {
    toutui = pkgs.callPackage ./pkgs/toutui {};
    daqp = pkgs.callPackage ./pkgs/daqp {};
    imap-backup = pkgs.callPackage ./pkgs/imap-backup {};
    vl-convert = pkgs.callPackage ./pkgs/vl-convert {};
    dedoc = pkgs.callPackage ./pkgs/dedoc {};
    age-edit = pkgs.callPackage ./pkgs/age-edit {};

    flatlatex = pkgs.python3Packages.callPackage ./pkgs/flatlatex {};
    sixelcrop = pkgs.python3Packages.callPackage ./pkgs/sixelcrop {};
    timg = pkgs.python3Packages.callPackage ./pkgs/timg {};
    euporie = pkgs.python3Packages.callPackage ./pkgs/euporie {inherit flatlatex sixelcrop timg;};
    aiolinkding = pkgs.python3Packages.callPackage ./pkgs/aiolinkding {};
    arro3-core = pkgs.python3Packages.callPackage ./pkgs/arro3-core {};
    linkding-cli = pkgs.python3Packages.callPackage ./pkgs/linkding-cli {inherit aiolinkding;};
    vegafusion = pkgs.python3Packages.callPackage ./pkgs/vegafusion {inherit arro3-core;};
    vl-convert-python = pkgs.python3Packages.callPackage ./pkgs/vl-convert-python {
      inherit vl-convert;
    };
  };
  supportedSystem = _: pkg: builtins.elem system pkg.meta.platforms;
in
  (pkgs.lib.filterAttrs supportedSystem packages) // aliases
