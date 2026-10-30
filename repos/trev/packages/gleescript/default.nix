{
  fetchFromGitHub,
  lib,
  mkGleamPackage,
  nix-update-script,
}:

mkGleamPackage (finalAttrs: {
  pname = "gleescript";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "lpil";
    repo = "gleescript";
    rev = "v${finalAttrs.version}";
    hash = "sha256-thKcoHYPM4/5oukpKIPIp8Q7HnhM6cvmBVWwWqmFnCg=";
  };

  gleamDepsHash = "sha256-syVA+0pueKjQHE3mR+QMbjfoZdWJttm0tJrSk/Ah6SU=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--custom-dep=gleamDeps"
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    mainProgram = "gleescript";
    description = "Bundles your Gleam-on-Erlang project into an escript";
    platforms = lib.platforms.all;
    homepage = "https://github.com/lpil/gleescript";
    changelog = "https://github.com/lpil/gleescript/releases/tag/v${finalAttrs.version}";
  };
})
