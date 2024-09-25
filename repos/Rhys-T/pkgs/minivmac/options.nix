{ pkgs ? import <nixpkgs> {} }: with pkgs;
let
    procStr = name: x: lib.optionalString (x != null) "-${name} ${lib.escapeShellArg x}";
    procInt = name: x: if builtins.isInt x then "-${name} ${toString x}" else throw "not an integer";
    procBool = name: x: "-${name} ${if x then "1" else "0"}";
    procBoolNoArg = name: x: if x then "-${name}" else "";
    procMapped = name: vals: x: "-${name} ${vals.${x}}";
    procEnum = name: vals: x: lib.pipe vals [
        (lib.imap0 (i: v: {inherit i v;}))
        (lib.findFirst ({i, v}: v == x) (throw "invalid value"))
        ({i, v}: "-${name} ${toString i}")
    ];
    withOrder = o: f: {__functor = self: f; order = o;};
    optProc = {
        targetCode = procStr "t";
        macType = procStr "m";
        localtalk = procBoolNoArg "lt";
        localtalkOver = procStr "lto";
        resolution = resStr: let
            resVals = builtins.split "x" resStr;
            width = builtins.elemAt resVals 0;
            height = builtins.elemAt resVals 2;
        in "-hres ${width} -vres ${height}";
        colorDepth = procEnum "depth" [ 1 2 4 8 16 32 ];
        speed = procMapped "speed" {
            "1x" = "z";
            "2x" = "1";
            "4x" = "2";
            "8x" = "3";
            "16x" = "4";
            "32x" = "5";
            "all out" = "a";
        };
        fullscreen = procBool "fullscreen";
        varFullscreen = procBool "var-fullscreen";
        magnify = procBool "magnify";
        magnifyFactor = procInt "mf";
        memory = procStr "mem";
        insertIthDisk = procBool "iid";
        keyMap = keyMap: builtins.concatStringsSep " " (lib.mapAttrsToList (realKey: macKey: "-km ${realKey} ${macKey}") keyMap);
        maintainer = procStr "maintainer";
        homepage = procStr "homepage";
        rawOptions = withOrder 100 (value: value);
    };
in rec {
    # takesOptions' = {f, variadic ? false}: let
    #   allArgs = (
    #       (lib.functionArgs f) //
    #       (lib.genAttrs (builtins.attrNames optProc) (x: true))
    #   );
    #   argCheckingF = if variadic then f else
    #       (x: ({}: f x) (removeAttrs x (builtins.attrNames allArgs)));
    #   fixedF = lib.setFunctionArgs argCheckingF allArgs;
    # in fixedF;
    # takesOptions = f: takesOptions' { inherit f; };
    defaultOptions = {
        maintainer = "Rhys-T on GitHub";
        homepage = "https://github.com/Rhys-T/nur-packages";
    };
    extractOptions = builtins.intersectAttrs optProc;
    buildOptionsFrom = opts: lib.pipe (extractOptions opts) [
        (lib.mapAttrsToList (name: value: {
            __toString = self: optProc.${name} value;
            order = optProc.${name}.order or 0;
        }))
        (builtins.sort (x: y: x.order < y.order))
        (builtins.map builtins.toString)
        (lib.lists.remove "")
        (builtins.concatStringsSep " ")
    ];
}
