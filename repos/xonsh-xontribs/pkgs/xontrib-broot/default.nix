{
  pkgs,
  python3,
}: let
  pname = "xontrib-broot";
  version = "0.2.1";
in
  python3.pkgs.buildPythonPackage {
    inherit pname version;

    src = pkgs.fetchFromGitHub {
      owner = "jnoortheen";
      repo = "xontrib-broot";
      rev = "6f658ff88aba27b921017297d8c2c3dfb2ffa332";
      sha256 = "sha256-9GqsTVCMvrWpTopHtEdicTyYRQzP1NVtQHZsfBT+fUg=";
    };

    doCheck = false;

    format = "pyproject";

    build-system = with pkgs.python3Packages; [
      setuptools
      pdm-pep517
      poetry-core
      pkgs.xonsh
    ];

    postPatch = ''
      sed -ie "/xonsh.*=/d" pyproject.toml
    '';

    meta = {
      homepage = "https://github.com/jnoortheen/xontrib-broot";
      license = pkgs.lib.licenses.mit;
      description = "[how-to use in nix](https://github.com/drmikecrowe/nur-packages) [broot](https://github.com/Canop/broot) support function for xonsh shell";
    };
  }
