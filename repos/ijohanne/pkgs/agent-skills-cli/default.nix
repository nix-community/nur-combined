{ pkgs, sources }:
pkgs.buildNpmPackage {
  pname = "agent-skills-cli";
  version = "1.1.7";
  src = sources.agent-skills-cli;
  npmDepsHash = "sha256-49WBTjOKfKOJYVx/Bjo3htoBBfLXzHOPfnIf8g+7D9U=";
  nodejs = pkgs.nodejs_22;
  meta.mainProgram = "skills";
}
