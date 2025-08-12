final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyfinal: pyprev: rec {
      dearpygui = pyfinal.callPackage ../pkgs/dearpygui/default.nix { };
      decompyle3 = pyfinal.callPackage ../pkgs/decompyle3/default.nix { inherit xdis; };
      flask-apscheduler = pyfinal.callPackage ../pkgs/flask-apscheduler/default.nix { };
      lib3to6 = pyfinal.callPackage ../pkgs/lib3to6/default.nix { };
      imgui = pyfinal.callPackage ../pkgs/pyimgui/default.nix { };
      markdown-katex = pyfinal.callPackage ../pkgs/markdown-katex/default.nix { inherit lib3to6; };
      protobuf-inspector = pyfinal.callPackage ../pkgs/protobuf-inspector/default.nix { };
      pyinstxtractor-ng = pyfinal.callPackage ../pkgs/pyinstxtractor-ng/default.nix { inherit xdis; };
      xasm = pyfinal.callPackage ../pkgs/xasm/default.nix { inherit xdis x-python; };
      xdis = if pyprev.xdis.version == "6.1.3" then (pyprev.xdis.overrideAttrs (final: old: {
        patches = [
          ../pkgs/xdis/xdis.patch
        ];
      })) else pyprev.xdis;
      x-python = pyfinal.callPackage ../pkgs/x-python/default.nix { inherit xdis; };
    })
  ];
}
