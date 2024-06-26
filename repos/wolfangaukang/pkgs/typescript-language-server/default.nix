{ lib
, mkYarnPackage
, fetchFromGitHub
, fetchYarnDeps
, makeWrapper
, nodejs
}:

mkYarnPackage rec {
  pname = "typescript-language-server";
  version = "4.3.3";

  src = fetchFromGitHub {
    owner = "typescript-language-server";
    repo = "typescript-language-server";
    rev = "v${version}";
    hash = "sha256-FCv0+tA7AuCdGeG6FEiMyRAHcl0WbezhNYLL7xp5FWU=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  packageJSON = ./package.json;

  offlineCache = fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    hash = "sha256-nSMhPfbWD93sGIKehBBE/bh4RzHXFtGAjeyG20m/LWQ=";
  };

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)
    yarn --offline build

    runHook postBuild
  '';

  postInstall = ''
    LSP_BIN="$out/bin/typescript-language-server"
    chmod +x "$LSP_BIN"
    wrapProgram "$LSP_BIN" --prefix PATH : "${nodejs}/bin"
  '';

  meta = {
    description = "TypeScript & JavaScript Language Server";
    homepage = "https://github.com/typescript-language-server/typescript-language-server";
    licenses = with lib.licenses; [ asl20 mit ];
    mainProgram = "typescript-language-server";
  };
}
