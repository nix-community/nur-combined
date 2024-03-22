{
  lib,
  buildGoModule,
  fetchFromGitHub,
  lazygit,
  testers,
}:
buildGoModule rec {
  pname = "lazygit";
  version = "2024-03-22-150cc706981ec6a6e1e4f79f1fbf09cb7af224fd";

  src = fetchFromGitHub {
    owner = "jesseduffield";
    repo = pname;
    rev = "150cc706981ec6a6e1e4f79f1fbf09cb7af224fd";
    hash = "sha256-arPjgEeJhWyFayU+qeb2gPGpW4o0lp9s1LX20gA+z2c=";
  };

  vendorHash = null;
  subPackages = ["."];

  ldflags = ["-X main.version=${version}" "-X main.buildSource=nix"];

  passthru.tests.version = testers.testVersion {
    package = lazygit;
  };

  meta = with lib; {
    description = "Simple terminal UI for git commands";
    homepage = "https://github.com/jesseduffield/lazygit";
    license = licenses.mit;
    mainProgram = "lazygit";
  };
}
