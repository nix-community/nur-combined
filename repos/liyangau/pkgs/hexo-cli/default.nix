{
  buildNpmPackage,
  lib,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "hexo-cli";
  version = "4.3.1";

  src = fetchFromGitHub {
    owner = "hexojs";
    repo = "hexo-cli";
    rev = "v${version}";
    hash = "sha256-mtbg9Fa9LBqG/aNfm4yEo4ymuaxuqhymkO1q6mYA2Fs=";
  };

  postPatch = ''
    sed -i 's/"git submodule init && git submodule update && git submodule foreach git pull origin master"/""/' package.json
  '';

  npmDepsHash = "sha256-VCHG1YMPRwEBbwgscSv6V+fTNVRpsCxWeyO8co4Zy6k=";

  dontNpmBuild = false;

  meta = {
    description = "Command line interface for Hexo.";
    license = lib.licenses.mit;
    homepage = "https://github.com/hexojs/hexo-cli";
  };
}
