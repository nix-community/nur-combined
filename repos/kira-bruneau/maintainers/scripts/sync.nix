# TODO: Push patches from NUR to nixpkgs repo

# TODO: Automatically determine the commit range by determining the
# last point where the paths were identical and by cherry picking the set
# patches after that point (a path-specific git-merge-base?).

{ rev
, lib
, writeText
, writeScript
, coreutils
, diffutils
, fd
, git
, gnused
, nix
}:

let
  syncPaths = writeText "sync-paths" (lib.concatStringsSep "\n" [
    "nixos/modules/hardware/xpadneo.nix"
    "nixos/modules/programs/bash/undistract-me.nix"
    "nixos/modules/programs/gamemode.nix"
    "nixos/modules/services/video/replay-sorcery.nix"
    "pkgs/applications/audio/zynaddsubfx"
    "pkgs/applications/editors/poke"
    "pkgs/applications/networking/cluster/krane"
    "pkgs/applications/networking/feedreaders/newsflash"
    "pkgs/applications/version-management/git-review"
    "pkgs/development/node-packages/node-env.nix"
    "pkgs/development/python-modules/debugpy"
    "pkgs/development/python-modules/pygls"
    "pkgs/development/python-modules/pytest-datadir"
    "pkgs/development/python-modules/vdf"
    "pkgs/development/tools/misc/ccache"
    "pkgs/development/tools/misc/cmake-language-server"
    "pkgs/development/tools/misc/texlab"
    "pkgs/games/clonehero"
    "pkgs/os-specific/linux/xpadneo"
    "pkgs/shells/bash/undistract-me"
    "pkgs/tools/audio/yabridge"
    "pkgs/tools/audio/yabridgectl"
    "pkgs/tools/games/gamemode"
    "pkgs/tools/graphics/goverlay"
    "pkgs/tools/graphics/mangohud"
    "pkgs/tools/graphics/vkBasalt"
    "pkgs/tools/package-management/protontricks"
    "pkgs/tools/video/replay-sorcery"
  ]);
in writeScript "sync" ''
  set -eu
  export PATH=${lib.makeBinPath [
    coreutils
    diffutils
    fd
    git
    gnused
    nix
  ]}

  nixpkgs_repo="$1"

  # Takes a set of paths passed through stdin and filters out paths
  # that have no difference against target repo.
  #
  # NOTE: Paths to directories are never actually "filtered out".
  # Instead, this will output negative matches for identical files
  # within the directory (":!<path>").
  function filter_identical_paths() {
    target_repo="$1"
    while IFS='$\n' read -r path; do
      if [ -d "$path" ]; then
        echo "$path"
        while IFS='$\n' read -r file; do
          exit_code=0
          cmp --quiet "$file" "$target_repo/$file" || exit_code=$?
          if [ $exit_code -eq 0 ]; then
            echo ":!$file"
          fi
        done < <(fd --type file --hidden . "$path")
      else
        exit_code=0
        cmp --quiet "$path" "$nixpkgs_repo/$path" || exit_code=$?
        if [ $exit_code -ne 0 ]; then
          echo "$path"
        fi
      fi
    done
  }

  # Similar to `git format-patch`, but filters the patches against the
  # set of paths passed through stdin.
  function format_filtered_patch() {
    repo=$1
    revision_range=$2
    sed -e '1i --' | git -C "$nixpkgs_repo" log \
        --stdin \
        --patch \
        --pretty=email \
        --reverse \
        --no-merges \
        "$revision_range"
  }

  # Do we need filter_identical_paths if we set this up so that we
  # never get out of sync? Let's assume the sync is imperfect for now,
  # and leave it in as a heuristic for skipping patches that have
  # already been applied.
  cat ${syncPaths} \
    | filter_identical_paths "$nixpkgs_repo" \
    | format_filtered_patch "$nixpkgs_repo" ${rev}..refs/remotes/origin/nixpkgs-unstable \
    | git am

  nix flake lock --update-input nixpkgs
''
