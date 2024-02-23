{ fetchFromGitHub, rtklib }:

rtklib.overrideAttrs (super: rec {
  pname = "rtklib-demo5";
  version = "b34i";

  src = fetchFromGitHub {
    owner = "rtklibexplorer";
    repo = "RTKLIB";
    rev = version;
    hash = "sha256-QVbmEGPSr/CZN9ljwO1oUQVs6ea5BNBXbK+WLHcxgUM=";
  };

  meta = rtklib.meta // {
    description = "A version of RTKLIB optimized for single and dual frequency low cost GPS receivers";
    homepage = "http://rtkexplorer.com/";
  };
})
