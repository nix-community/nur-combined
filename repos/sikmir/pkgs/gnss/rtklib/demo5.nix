{ fetchFromGitHub, rtklib }:

rtklib.overrideAttrs (super: rec {
  pname = "rtklib-demo5";
  version = "b34j";

  src = fetchFromGitHub {
    owner = "rtklibexplorer";
    repo = "RTKLIB";
    rev = version;
    hash = "sha256-pLsN1WcNVxIe8DoPFZW0X3gledy5VvtOMXhVj+xPikQ=";
  };

  meta = rtklib.meta // {
    description = "A version of RTKLIB optimized for single and dual frequency low cost GPS receivers";
    homepage = "http://rtkexplorer.com/";
  };
})
