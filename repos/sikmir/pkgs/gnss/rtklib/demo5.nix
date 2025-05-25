{ fetchFromGitHub, rtklib }:

rtklib.overrideAttrs (super: rec {
  pname = "rtklib-demo5";
  version = "b34L";

  src = fetchFromGitHub {
    owner = "rtklibexplorer";
    repo = "RTKLIB";
    tag = version;
    hash = "sha256-bQcia3aRQNcZ55fvJViAxpo2Ev276HFTZ28SEXJD5Ds=";
  };

  meta = rtklib.meta // {
    description = "A version of RTKLIB optimized for single and dual frequency low cost GPS receivers";
    homepage = "http://rtkexplorer.com/";
  };
})
