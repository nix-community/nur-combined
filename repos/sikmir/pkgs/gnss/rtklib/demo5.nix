{ fetchFromGitHub, rtklib }:

rtklib.overrideAttrs (super: rec {
  pname = "rtklib-demo5";
  version = "b34k";

  src = fetchFromGitHub {
    owner = "rtklibexplorer";
    repo = "RTKLIB";
    tag = version;
    hash = "sha256-ctfHNdzsxY6oCrmPME0yx5WNyWfAK6bPsnvz3C1uEjY=";
  };

  meta = rtklib.meta // {
    description = "A version of RTKLIB optimized for single and dual frequency low cost GPS receivers";
    homepage = "http://rtkexplorer.com/";
  };
})
