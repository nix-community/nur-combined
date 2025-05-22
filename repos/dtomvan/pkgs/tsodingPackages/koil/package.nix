{
  lib,
  llvmPackages_19,
  glibc_multi,
  c3c,
  fetchFromGitHub,
  buildNpmPackage,
  http-server,
  writeShellScript,
  replaceVars,
  makeWrapper,
  nix-update-script,

  koil,
  testers,
}:
let
  llvmPackages = llvmPackages_19;
  cc = llvmPackages.clang;
  ourc3c = c3c.overrideAttrs {
    version = "0.6.8"; # or versionCheckHook will complain
    src = fetchFromGitHub {
      owner = "c3lang";
      repo = "c3c";
      rev = "855be9288121d0f7a67d277f7bbbbf57fbfa2597";
      hash = "sha256-atG6wbVLPRU8bnzOHboQyxbYATr6FSMHp5ZcpIyJLLo=";
    };

    doCheck = false; # oh such a bummer (just takes too long, this is not even production ready yet)
  };
  serve = writeShellScript "koil-serve.sh" ''
    set -x

    koil-server &
    ${lib.getExe http-server} -p ''${KOIL_PORT:-6969} -a 0.0.0.0 -g -c-1 &

    cleanup () { kill 0; }
    trap cleanup SIGINT

    wait
  '';
in
buildNpmPackage {
  pname = "koil";
  version = "0-unstable-2025-05-11";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "koil";
    rev = "3ab5b3fc4d4e00158311b2cf81d50ae51610d897";
    hash = "sha256-KRWVoOcipKHVmNksshGjfxboC4eU73k8dNCL5yzMGRw=";
  };

  patches = [
    (replaceVars ./use-different-wasm32-compiler.patch {
      GLIBC = glibc_multi.dev;
      CLANG = cc.passthru.cc.lib;
    })
  ];

  nativeBuildInputs = [
    cc
    ourc3c
    makeWrapper
  ];

  npmDepsHash = "sha256-d+LGpFoThvA7KnFqEhnJSPhj+jQcvc399Iv7YJ5ZtVw=";

  # those are checked out in git
  preBuild = ''
    rm -rf build
    rm -f client.wasm client.mjs
  '';

  postInstall = ''
    mkdir $out/bin
    cp build/server $out/bin/koil-server
    cp build/packer $out/bin/koil-packer
    cp index.html client.wasm client.mjs $out

    makeWrapper ${serve} $out/bin/koil-serve \
      --prefix PATH ":" $out/bin \
      --chdir $out
  '';

  passthru = {
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
    tests.koil = testers.runNixOSTest {
      imports = [ ../../tests/koil.nix ];
      defaults.services.koil.package = koil;
    };
  };

  meta = {
    description = "Online Multiplayer Browser Game with Old-School Raycasting Graphics";
    homepage = "https://github.com/tsoding/koil";
    licenses = lib.licenses.mit;
    mainProgram = "koil-serve";
  };
}
