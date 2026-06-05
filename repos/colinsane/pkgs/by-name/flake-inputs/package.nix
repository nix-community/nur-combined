# use like:
# ```nix
# flake-inputs.import-flake {
#   src = fetchFromGitHub { ... };
#   overrides = {
#     # provide your own source to some entry in the flake's `inputs`
#     nixpkgs = nixpkgs-bootstrap.master;
#   };
# }
# ```
#
# N.B.: `overrides` is an open attrset; flake-inputs does not error if you override an input that the src doesn't accept.
{
  fetchFromGitHub,
  gitUpdater,
}:
let
  version = "4.1.0";
  src = fetchFromGitHub {
    owner = "fricklerhandwerk";
    repo = "flake-inputs";
    tag = version;
    hash = "sha256-dSECtDeIOGKGsbEOOcOHbZ2NYDy0D/x0hlbiKvpWp8g=";
  };
  defaultNix = import src;
in src.overrideAttrs (base: {
  # attributes required by update scripts
  pname = "flake-inputs";
  src = src;
  version = version;
  # make it so `pkgs.flake-inputs` is callable directly, while also being a derivation
  passthru = base.passthru // {
    inherit defaultNix;
    inherit (defaultNix) import-flake;
    updateScript = gitUpdater { };
  };
  meta = base.meta // {
    homepage = "https://github.com/fricklerhandwerk/flake-inputs";
    description = "A helper to use flakes from stable Nix";
  };
})
