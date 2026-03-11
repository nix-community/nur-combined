{
  fetchFromGitHub,
  gleam,
  lib,
  nix-update-script,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "go-over";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "bwireman";
    repo = "go-over";
    rev = "v${finalAttrs.version}";
    hash = "sha256-I2r0kKxqWMNSqg/tj23A7eljrW8R5TnGSEX8Ltr7dZA=";
  };

  gleamDeps = gleam.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-FvxML+hkpi1YIPq3+Uk1pyBnwt5m4JggkQxvEfeFNdM=";
  };

  nativeBuildInputs = [
    gleam.erlangHook
  ];

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--flake"
        "--commit"
        finalAttrs.pname
      ];
    };
  };

  meta = {
    description = "Audits Erlang & Elixir dependencies";
    mainProgram = "go_over";
    homepage = "https://github.com/bwireman/go-over";
    changelog = "https://github.com/bwireman/go-over/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
