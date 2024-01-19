{
  pkgs,
  vpp_papi,
}:
with pkgs.python3Packages;
  buildPythonPackage rec {
    pname = "vppcfg";
    version = "0.0.4";

    src = pkgs.fetchFromGitHub {
      owner = "pimvanpelt";
      repo = "vppcfg";
      rev = "9da5be23fa000f5beaa039bd281abbd044758710";
      hash = "sha256-2fEr+8KHi/LJSEm+FGvhHqFwwXZoO1CopWxTFz7woaE=";
    };

    postPatch = ''
      # Test fails, unfortunately.
      rm vppcfg/config/test_acl.py
    '';

    propagatedBuildInputs = [requests importlib-metadata yamale netaddr vpp_papi];
  }
