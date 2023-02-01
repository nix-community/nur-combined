self: super:

{
  __MkPythonOverlay = name: arg: newself: newsuper: {
    python3 = newsuper.python3 // {
      pkgs = newsuper.python3.pkgs.overrideScope
        (pyself: pysuper: { ${name} = pysuper.${name}.overrideAttrs arg; });
      withPackages = import (newsuper.path
        + "/pkgs/development/interpreters/python/with-packages.nix") {
          inherit (newself.python3) buildEnv;
          pythonPackages = newself.python3.pkgs;
        };
    };
    python311 = newsuper.python311 // {
      pkgs = newsuper.python311.pkgs.overrideScope
        (pyself: pysuper: { ${name} = pysuper.${name}.overrideAttrs arg; });
      withPackages = import (newsuper.path
        + "/pkgs/development/interpreters/python/with-packages.nix") {
          inherit (newself.python311) buildEnv;
          pythonPackages = newself.python311.pkgs;
        };
    };
    python3Packages = newself.python3.pkgs;
    python311Packages = newself.python311.pkgs;
    hy = newsuper.hy.override { python = newself.python3; };
  };
}
