# TODO: Push patches from NUR to nixpkgs repo

# TODO: Automatically determine the commit range by determining the
# last point where the paths were identical and by cherry picking the set
# patches after that point (a path-specific git-merge-base?).

{
  nixpkgs,
  lib,
  writeText,
  writeShellApplication,
  coreutils,
  diffutils,
  fd,
  git,
  gnused,
  ncurses,
  nix,
  nix-fast-build,
  update,
}:

let
  syncPaths = writeText "sync-paths" (
    lib.concatStringsSep "\n" [
      "nixos/modules/hardware/video/intel-gpu-tools.nix"
      "nixos/modules/hardware/xpadneo.nix"
      "nixos/modules/programs/bash/undistract-me.nix"
      "nixos/modules/programs/gamemode.nix"

      "nixos/tests/xpadneo.nix"

      "pkgs/applications/audio/zynaddsubfx"
      "pkgs/applications/editors/emacs/elisp-packages/manual-packages/acm"
      "pkgs/applications/editors/emacs/elisp-packages/manual-packages/acm-terminal"
      "pkgs/applications/editors/emacs/elisp-packages/manual-packages/lsp-bridge"
      "pkgs/development/python-modules/debugpy"
      "pkgs/development/python-modules/pygls"
      "pkgs/development/python-modules/pytest-datadir"
      "pkgs/development/python-modules/vdf"
      "pkgs/os-specific/linux/xpadneo"
      "pkgs/tools/audio/yabridge"
      "pkgs/tools/audio/yabridgectl"
      "pkgs/tools/games/gamemode"
      "pkgs/tools/graphics/mangohud"
      "pkgs/tools/graphics/vkbasalt"
      "pkgs/tools/package-management/protontricks"

      "pkgs/by-name/cc/ccache"
      "pkgs/by-name/cl/clonehero"
      "pkgs/by-name/cm/cmake-language-server"
      "pkgs/by-name/ga/gamemode"
      "pkgs/by-name/gi/git-review"
      "pkgs/by-name/ma/mangohud"
      "pkgs/by-name/mo/mozlz4a"
      "pkgs/by-name/ne/newsflash"
      "pkgs/by-name/po/poke"
      "pkgs/by-name/po/pokemmo-installer"
      "pkgs/by-name/te/texlab"
      "pkgs/by-name/uk/ukmm"
      "pkgs/by-name/un/undistract-me"
      "pkgs/by-name/vk/vkbasalt"
      "pkgs/by-name/xp/xpadneo"
      "pkgs/by-name/ya/yabridge"
      "pkgs/by-name/ya/yabridgectl"
      "pkgs/by-name/ya/yarg"
      "pkgs/by-name/zy/zynaddsubfx"
    ]
  );
in
writeShellApplication {
  name = "sync";
  runtimeInputs = [
    coreutils
    diffutils
    fd
    git
    gnused
    ncurses
    nix
    nix-fast-build
    update
  ];

  text = ''
    nixpkgs_repo="$1"

    # Takes a set of paths passed through stdin and filters out paths
    # that have no difference against target repo.
    #
    # NOTE: Paths to directories are never actually "filtered out".
    # Instead, this will output negative matches for identical files
    # within the directory (":!<path>").
    function filter_identical_paths() {
      repo="$1"
      while IFS=$'\n' read -r path; do
        if [ -d "$path" ]; then
          echo "$path"
          while IFS=$'\n' read -r file; do
            exit_code=0
            cmp --quiet "$file" "$repo/$file" || exit_code=$?
            if [ $exit_code -eq 0 ]; then
              echo ":!$file"
            fi
          done < <(fd --type file --hidden . "$path")
        else
          exit_code=0
          cmp --quiet "$path" "$repo/$path" || exit_code=$?
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
      sed -e '1i --' | git -C "$repo" log \
          --stdin \
          --patch \
          --pretty=email \
          --reverse \
          --no-merges \
          "$revision_range"
    }

    git pull &
    git -C "$nixpkgs_repo" pull &
    for p in $(jobs -p); do
       wait "$p"
    done

    git switch --quiet --detach '@{u}'

    # Do we need filter_identical_paths if we set this up so that we
    # never get out of sync? Let's assume the sync is imperfect for now,
    # and leave it in as a heuristic for skipping patches that have
    # already been applied.
    filter_identical_paths "$nixpkgs_repo" < ${syncPaths} \
      | format_filtered_patch "$nixpkgs_repo" ${nixpkgs.rev}..refs/remotes/origin/nixpkgs-unstable \
      | git am

    nix flake update
    git add flake.lock
    git commit --message 'flake.lock: update' --quiet || :

    update

    build_flags=()
    if ! infocmp -1 | grep clear; then
      build_flags+=(--no-nom)
    fi

    nix-fast-build --no-download "''${build_flags[@]}"
    git switch --quiet -
    git rebase 'HEAD@{1}'
  '';
}
