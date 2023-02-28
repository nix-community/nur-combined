{ buildNpmPackage, lib, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "hexo-cli";
  version = "4.3.0";

  src = fetchFromGitHub {
    owner = "hexojs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-4VI5M71z3QD5TrrRoiXrSZasAQosQpLBw9l/6tLCX3M=";
  };
  postPatch = ''
    sed -i 's/"git submodule init && git submodule update && git submodule foreach git pull origin master"/""/' package.json
  '';

  npmDepsHash = "sha256-SPIFddj/cLkxXdF0gmwmT+Xk/EN0xKVycDxigq9M16k=";

  dontNpmBuild = true;

  meta = {
    description = "Command line interface for Hexo.";
    license = lib.licenses.mit;
    homepage = "https://github.com/hexojs/hexo-cli";
  };
}
