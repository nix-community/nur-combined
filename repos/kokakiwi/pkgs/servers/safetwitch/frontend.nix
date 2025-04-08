{
  lib,
  fetchFromGitea,
  buildNpmPackage,
  nodejs_22,
  gitMinimal,
}:
buildNpmPackage rec {
  pname = "safetwitch-frontend";
  version = "2.4.5";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "SafeTwitch";
    repo = "safetwitch";
    rev = "v${version}";
    hash = "sha256-hgEI4NxQaisqeATrgyZjWfnPgyhYsij+g0nih+wfAD4=";
    fetchSubmodules = true;
  };

  nodejs = nodejs_22;
  npmFlags = [ "--legacy-peer-deps" ];

  npmDepsHash = "sha256-bagRIa5K4hOeB4e5TzjWRmlsUMQG6GQA4Gdye5/G0t0=";

  nativeBuildInputs = [
    gitMinimal
  ];

  installPhase = ''
    runHook preBuild

    mkdir -p $out/share/safetwitch
    cp -r -t $out/share/safetwitch dist/*

    runHook postBuild
  '';

  meta = {
    description = "A privacy respecting frontend for twitch.tv";
    homepage = "https://codeberg.org/SafeTwitch/safetwitch-backend";
    license = lib.licenses.agpl3Only;
  };
}
