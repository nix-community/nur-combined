/*
TODO build frontend with npmlock2nix + yaml parser + pnpm lockfile ...

TODO init config file from default config
https://github.com/crawlab-team/crawlab/issues/1483
https://github.com/crawlab-team/crawlab-core/raw/main/config/default_config.go
*/

{ lib
, stdenv
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "crawlab";
  version = "0.6.3";

  src = (fetchFromGitHub {
    owner = "crawlab-team";
    repo = "crawlab";
    rev = "v${version}";
    hash = "sha256-u2CScHJesHHN+FhST0iK/WtzfGzGWg+rFh3CFeHyruQ=";
    fetchSubmodules = true;
  }) + "/backend";

  vendorHash = "sha256-yFb5arwsasFarHkXH9o0TeSwojK5+2RkXHape1weezI=";

  meta = with lib; {
    description = "Distributed web crawler admin platform for spiders management regardless of languages and frameworks";
    homepage = "https://github.com/crawlab-team/crawlab";
    changelog = "https://github.com/crawlab-team/crawlab/raw/v${version}/CHANGELOG.md";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    mainProgram = "crawlab";
    platforms = platforms.all;
  };
}
