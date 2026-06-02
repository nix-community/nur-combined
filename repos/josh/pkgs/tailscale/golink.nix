{
  lib,
  buildGoModule,
  fetchFromGitHub,
  go,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "golink";
  version = "1.0.0-unstable-2026-02-25";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "golink";
    rev = "4036fc3a9694944dfd48586ea939212360391b22";
    hash = "sha256-8Q5UF0PQzMcY/zaJVssZCaXXizSBEHrecBk3qaw1al0=";
  };

  vendorHash = "sha256-Mlc7TgP23t5DQl5Hp5iex77BAP+eDf69M3XlK7azsro=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  # TODO: re-enable once nixpkgs has go 1.26
  # passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    help = runCommand "test-golink-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
      golink --help
      touch $out
    '';
  };

  meta = {
    description = "Private shortlink service for tailnets";
    homepage = "https://github.com/tailscale/golink";
    license = lib.licenses.bsd3;
    mainProgram = "golink";
    broken = lib.strings.versionOlder go.version "1.25.1";
  };
})
