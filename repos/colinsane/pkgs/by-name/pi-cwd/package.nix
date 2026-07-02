{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-cwd";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "harms-haus";
    repo = "pi-cwd";
    rev = "7af506e696d214f0ee7087e817d2ee142b28a6b7";
    hash = "sha256-P7t6E6qdRJyf+gBEMKAT/cI0rlX7CJqNSrclUT92JN4=";
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-yP8ytIABHCD/61J1ZouWe4tbViI616waih2RkmXW6fc=";

  makeCacheWritable = true;

  npmFlags = [ "--legacy-peer-deps" ];

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  postInstall = ''
    mv $out/lib/node_modules/@harms-haus/pi-cwd/* $out
    rmdir $out/lib/node_modules/@harms-haus/pi-cwd
    rmdir $out/lib/node_modules/@harms-haus
    rmdir $out/lib/node_modules/
    rmdir $out/lib
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--generate-lockfile"
    ];
  };

  meta = {
    description = "Change working directory inside the agent tui";
    homepage = "https://github.com/harms-haus/pi-cwd";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})