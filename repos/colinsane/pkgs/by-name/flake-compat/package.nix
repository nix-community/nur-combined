# N.B.: flake-compat is able to resolve most flake outputs,
# but there's no way to override the flake's inputs: it always takes from flake.lock.
# - <https://git.lix.systems/lix-project/flake-compat/issues/82>
#
# N.B.: `(flake-compat args).outputs.overrideAttrs { }` behaves strangely;
# the result is effectively `flake-compat args`.
# this is likely an upstream issue.
#
# see also:
# - <https://github.com/fricklerhandwerk/flake-inputs>
#   - possibly supports input overriding?
# - <https://github.com/nix-community/dream2nix/blob/main/dev-flake/flake-compat.nix>
{
  fetchFromGitea,
  lib,
  nix-update-script,
  stdenv,
}:
let
  version = "0-unstable-2026-05-02";
  src = fetchFromGitea {
    domain = "git.lix.systems";
    owner = "lix-project";
    repo = "flake-compat";
    rev = "382052b74656a369c5408822af3f2501e9b1af81";
    hash = "sha256-Eg9b/rq/ECYwNwEXs5i9wHyhxNI0JrYx2srdI2uZMaQ=";
  };

  # args:
  # - src
  # - copySourceTreeToStore ? true
  # - useBuiltinsFetchTree ? false
  # - system
  # i'm just re-exporting this with a better default for `system`.
  main = args: import "${src}" ({
    system = stdenv.hostPlatform.system;
  } // args);

  flake-compat = src.overrideAttrs (base: {
    # attributes required by update scripts
    pname = "flake-compat";
    src = src;
    version = version;

    passthru = base.passthru // {
      updateScript = nix-update-script {
        extraArgs = [ "--version" "branch" ];
      };
    };

    meta = {
      homepage = "https://git.lix.systems/lix-project/flake-compat";
      description = "Turns Nix flakes into normal Nix expressions";
      longDescription = ''
        Output attributes

        - inputs - the same inputs that a flake would receive in the outputs function.
        - defaultNix - the outputs of a flake; what you would see in nix repl .#, plus a default attribute of the default package.
        - shellNix - the same as defaultNix, but with default as the default dev shell rather than the default package.

        Input attributes

        - src - the source tree to use, containing flake.nix. Generally ./. or similar.

        - copySourceTreeToStore - whether to copy the flake's source tree to the Nix store.

          By default Lix flake-compat behaves the same as native flakes and copies the flake's source tree to the Nix store. This option allows for faster evaluation by skipping this copy and breaking strict compatibility with flakes if desired.

          Setting this to false may lead to the content of gitignored paths or the absolute path of the flake being evaluated leaking into the evaluation. We strongly recommend using nix-diff to verify evaluation produces the smae result. Here be (some) dragons.

          See Copying to the store.

          Default: true.

        - useBuiltinsFetchTree - whether to use builtins.fetchTree in place of flake-compat's Nix language implementation of it. If enabled and if builtins.fetchTree is present, it will be used. This will throw an error if using Lix older than 2.93 or CppNix <=2.18.x with flakes disabled due to a bug in the Nix implementation.

          The benefit of using this setting is that it will expose the full functionality (and bug-compatible behaviour) of the built-in flake implementation's fetchers and thus eliminate some possible evaluation divergences by doing the exact same thing as native flakes for fetching.

          Default: false.

        - system - the attributes to expose as .default from devShells and packages for default.nix and shell.nix. Default: builtins.currentSystem.
      '';
    };
  });
in
  # make it so `pkgs.flake-compat` is callable directly, while also being a derivation
  flake-compat // lib.setFunctionArgs main {
    # the following arguments do (true) or don't (false) have defaults
    src = false;
    copySourceTreeToStore = true;
    useBuiltinsFetchTree = true;
    system = true;
  }
