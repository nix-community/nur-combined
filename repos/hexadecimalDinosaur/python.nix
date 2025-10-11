{ pkgs, lib, ... }:
let
  xdis-patch-script = ./pkgs/xdis/xdis_patcher.sh;
in
version: pyfinal: pyprev:
let
  xdis = pyprev.xdis.overrideAttrs (final: old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.pcre ];
    postPatch = (old.postPatch or '''') + ''
      bash ${xdis-patch-script} ${if (pyfinal.python.implementation == "cpython") then pyfinal.python.version else pyfinal.python.pythonVersion}
    '';
  });
in
(rec {
  dearpygui = pyfinal.callPackage ./pkgs/dearpygui/default.nix { };
  decompyle3 = pyfinal.callPackage ./pkgs/decompyle3/default.nix { inherit xdis; };
  doc2dash = pyfinal.callPackage ./pkgs/doc2dash/default.nix { };
  flask-apscheduler = pyfinal.callPackage ./pkgs/flask-apscheduler/default.nix { };
  lib3to6 = pyfinal.callPackage ./pkgs/lib3to6/default.nix { };
  markdown-katex = pyfinal.callPackage ./pkgs/markdown-katex/default.nix { inherit lib3to6; };
  protobuf-inspector = pyfinal.callPackage ./pkgs/protobuf-inspector/default.nix { };
  pyghidra = pyfinal.callPackage ./pkgs/pyghidra/default.nix { };
  pyinstxtractor-ng = pyfinal.callPackage ./pkgs/pyinstxtractor-ng/default.nix { inherit xdis; };
  xasm = pyfinal.callPackage ./pkgs/xasm/default.nix { inherit xdis x-python; };
  inherit xdis;
  x-python = pyfinal.callPackage ./pkgs/x-python/default.nix { inherit xdis; };
} //
(if ((version == null) || ((lib.toInt (lib.versions.minor version)) < 13)) then {
  imgui = pyfinal.callPackage ./pkgs/pyimgui/default.nix { };
} else {}) //
(if ((version == null) || ((lib.toInt (lib.versions.minor version)) >= 12)) then {
  pylingual = pyfinal.callPackage ./pkgs/pylingual/default.nix { inherit xdis; };
} else {}))
