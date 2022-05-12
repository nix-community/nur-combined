{ pkgs ? import <nixpkgs> { } }:

let inherit (pkgs) callPackage recurseIntoAttrs;
in rec {
  lib = callPackage ./lib.nix { };

  hyperspec = callPackage ./pkgs/hyperspec { };

  luaPackages = lua53Packages;

  lua53Packages = recurseIntoAttrs {
    lua-curl = pkgs.lua53Packages.callPackage ./pkgs/lua-curl { };
  };

  python3Packages = recurseIntoAttrs
    (pkgs.lib.makeScope pkgs.python3Packages.newScope (py3: {
      asyncer = py3.callPackage ./pkgs/asyncer { };
      vosk = py3.callPackage ./pkgs/libvosk/python.nix { inherit libvosk; };
      dbussy = py3.callPackage ./pkgs/dbussy { };
      colorpedia = py3.callPackage ./pkgs/colorpedia { };
      ssort = py3.callPackage ./pkgs/ssort { };
      extcolors = py3.callPackage ./pkgs/extcolors { };
      convcolors = py3.callPackage ./pkgs/convcolors { };
      pymatting = py3.callPackage ./pkgs/pymatting { };
      rembg = py3.callPackage ./pkgs/rembg { };
      warctools = py3.callPackage ./pkgs/warctools { };
      blender-file = py3.callPackage ./pkgs/blender-file { };
      blender-asset-tracer = py3.callPackage ./pkgs/blender-asset-tracer { };
    }));

  schemaorg = callPackage ./pkgs/schemaorg { };

  libetc = callPackage ./pkgs/libetc { };

  gh-dash = callPackage ./pkgs/gh-dash { };

  lttoolbox = callPackage ./pkgs/lttoolbox { };

  apertium = callPackage ./pkgs/apertium { inherit lttoolbox; };

  lunasvg = callPackage ./pkgs/lunasvg { };

  lispPackages = recurseIntoAttrs {
    vacietis = callPackage ./pkgs/vacietis { };
    dbus = callPackage ./pkgs/cl-dbus/default.nix { };
  };

  rustfilt = callPackage ./pkgs/rustfilt { };

  bollux = callPackage ./pkgs/bollux { };

  gemget = callPackage ./pkgs/gemget { };

  cpp-httplib = callPackage ./pkgs/cpp-httplib { };

  cxxtimer = callPackage ./pkgs/cxxtimer { };

  cxxmatrix = callPackage ./pkgs/cxxmatrix { };

  hackernews-tui = callPackage ./pkgs/hackernews-tui { };

  har-tools = callPackage ./pkgs/har-tools { };

  ksuid = callPackage ./pkgs/ksuid { };

  wagi = callPackage ./pkgs/wagi { };

  bindle = callPackage ./pkgs/bindle { };

  pigo = callPackage ./pkgs/pigo { };

  htmlq = callPackage ./pkgs/htmlq { };

  libvosk = callPackage ./pkgs/libvosk { };

  s-dot = callPackage ./pkgs/s-dot { };

  s-dot2 = callPackage ./pkgs/s-dot2 { };

  tinmop = callPackage ./pkgs/tinmop { };

  cl-opengl = callPackage ./pkgs/cl-opengl { };

  cl-raylib = callPackage ./pkgs/cl-raylib { };

  ksv = callPackage ./pkgs/ksv { };

  sasl2-oauth = callPackage ./pkgs/sasl2-oauth { };

  oauth2ms = pkgs.callPackage ./pkgs/oauth2ms { };

  q = callPackage ./pkgs/q { };

  snid = callPackage ./pkgs/snid { };

  npt = callPackage ./pkgs/npt { };

  rust-u2f = callPackage ./pkgs/rust-u2f { };

  u8strings = callPackage ./pkgs/u8strings { };

  bzip3 = callPackage ./pkgs/bzip3 { };
}
