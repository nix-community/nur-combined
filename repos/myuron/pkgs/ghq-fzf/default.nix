{
  lib,
  fishPlugins,
  fetchFromGitHub,
}:
fishPlugins.buildFishPlugin {
  pname = "ghq-fzf";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "myuron";
    repo = "ghq-fzf.fish";
    rev = "bfef2e94efe0a37183309ec3cad11279e9bd7681";
    hash = "sha256-+mHM+E/4fEfDtoSLbXQm1kglLSetWPvAU3jBVmGy2ag=";
  };

  meta = {
    description = "Search ghq-managed repositories with fzf and cd into the selection, in fish";
    homepage = "https://github.com/myuron/ghq-fzf.fish";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
}
