# git built from sylr's fork (upstream release + .gitcleanignore support).
#
# Reuses nixpkgs' git recipe and only swaps the source, so build flags,
# wrappers, man pages and the test suite stay in sync with nixpkgs.
#
# To bump: set `version` to the new fork tag without its leading "v"
# (e.g. 2.56.0+sylr.2), set `hash = "";`, build once and paste the hash
# nix reports.
{ lib
, git
, fetchFromGitHub
, autoreconfHook
}:

git.overrideAttrs (old: rec {
  pname = "git-sylr";
  version = "2.56.0+sylr.3";

  src = fetchFromGitHub {
    owner = "sylr";
    repo = "git";
    tag = "v${version}";
    hash = "sha256-boSlnobJ3I59lUuHTD9wCrlvzRkrd/Vkfm7GCm/KCk4=";
  };

  # Older nixpkgs revisions (flake.lock, nixos-26.05) carry backports for
  # their own git version: fetchurl'd lore.kernel.org patches and the
  # osxkeychain Rust link fix. None applies to 2.56, so keep only the
  # Nix-specific patches vendored in nixpkgs (path fixes).
  patches = builtins.filter
    (p: builtins.isPath p && baseNameOf p != "osxkeychain-link-rust_lib.patch")
    (old.patches or [ ]);

  # The rest backports what newer nixpkgs (git 2.56 recipe) does for the
  # Linux test suite, so the older revisions pass too:
  #
  # separateDebugInfo exports $debug (the debug output path), which git's
  # test suite reads as --debug; its extra output then breaks TAP parsing.
  installCheckFlags = (old.installCheckFlags or [ ])
    ++ lib.optional (!lib.elem "debug=" (old.installCheckFlags or [ ])) "debug=";
  # t1517 fails because `git gui--askyesno` is installed; the upstream fix
  # (dropped above) no longer applies to 2.56 and was never merged.
  # disable_test comes from the nixpkgs recipe and tolerates repeats.
  preInstallCheck = (old.preInstallCheck or "") + ''
    disable_test t1517-outside-repo
  '';

  # A GitHub tarball has neither the generated ./configure nor the
  # `version` file that release tarballs ship. Without .git, GIT-VERSION-GEN
  # cannot run `git describe` and reads the version from that file.
  nativeBuildInputs = old.nativeBuildInputs ++ [ autoreconfHook ];
  postPatch = (old.postPatch or "") + ''
    echo ${version} > version
  '';

  meta = old.meta // {
    description = "Distributed version control system (sylr's fork with .gitcleanignore support)";
    homepage = "https://github.com/sylr/git/tree/v2.56+sylr";
  };
})
