{
  fetchFromGitHub,
  gleam,
  lib,
  nix-update-script,
}:
gleam.build rec {
  pname = "gleescript";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "lpil";
    repo = "gleescript";
    rev = "v${version}";
    hash = "sha256-thKcoHYPM4/5oukpKIPIp8Q7HnhM6cvmBVWwWqmFnCg=";
  };

  target = "erlang";

  passthru = {
    ifd = true;
    updateScript = nix-update-script {
      extraArgs = [
        "--flake"
        "--commit"
        "${pname}"
      ];
    };
  };

  meta = {
    description = "Bundles your Gleam-on-Erlang project into an escript";
    mainProgram = "gleescript";
    homepage = "https://github.com/lpil/gleescript";
    changelog = "https://github.com/lpil/gleescript/releases/tag/v${version}";
    platforms = lib.platforms.all;
  };
}
