{
  fetchFromGitHub,
  gleam,
  lib,
  nix-update-script,
}:
gleam.build rec {
  pname = "go-over";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "bwireman";
    repo = "go-over";
    rev = "v${version}";
    hash = "sha256-I2r0kKxqWMNSqg/tj23A7eljrW8R5TnGSEX8Ltr7dZA=";
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
    description = "Audits Erlang & Elixir dependencies";
    mainProgram = "go_over";
    homepage = "https://github.com/bwireman/go-over";
    changelog = "https://github.com/bwireman/go-over/releases/tag/v${version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
