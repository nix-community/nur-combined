{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  wrapFirefoxAddonsHook,
}:
buildNpmPackage (finalAttrs: {
  pname = "sidebery";
  version = "5.6.1";
  src = fetchFromGitHub {
    owner = "mbnuqw";
    repo = "sidebery";
    rev = "v${finalAttrs.version}";
    hash = "sha256-s1ynCWDofd4vlTT4mfOXnQX4hoTgS2BgWzzy9MCg5Fg=";
  };

  npmDepsHash = "sha256-HkTuLkyvtzM6mPRedEeDhZqiVSuqWn2pSQlgz7ssYok=";

  nativeBuildInputs = [
    wrapFirefoxAddonsHook
  ];

  postBuild = ''
    npm run build.ext
  '';

  installPhase = ''
    mkdir $out
    cp dist/* $out/$extid.xpi
  '';

  extid = "{3c078156-979c-498b-8990-85f7987dd929}";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--generate-lockfile"
    ];
  };

  meta = {
    homepage = "https://github.com/mbnuqw/sidebery";
    description = "Firefox extension for managing tabs and bookmarks in sidebar";
    maintainer = with lib.maintainers; [ colinsane ];
  };
})
