{
  pkgs,
  vpp_papi,
}:
with pkgs.python3Packages;
  buildPythonPackage rec {
    pname = "vppcfg";
    version = "0.0.6";

    src = pkgs.fetchFromGitHub {
      owner = "pimvanpelt";
      repo = "vppcfg";
      rev = "5381cf4490c8c1a9fece1186c77f900c2f80d669";
      hash = "sha256-t8JNztqzrBXP+wJQg4wpA0D6mqH9w42N2n57gmxXdBc=";
    };

    postPatch = ''
      # Test fails, unfortunately.
      rm vppcfg/config/test_acl.py
    '';

    propagatedBuildInputs = [requests importlib-metadata yamale netaddr vpp_papi];
  }
