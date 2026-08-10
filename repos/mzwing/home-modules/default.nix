# Module index for NUR and flake consumers. This file must stay importable
# without pkgs or lib: NUR evaluates the repository's default.nix with
# pkgs = throw when publishing modules under repos.<name>.modules.homeManager.*,
# so any dependency on pkgs here breaks that path.
(import ../internal/discover.nix {}).subdirs ./.
