{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.dots.git.wut;

  wutScript = pkgs.writeShellScript "wut" ''
    set -euo pipefail

    VERSION="0.1.2"

    # ============================================================================
    # Helpers
    # ============================================================================

    fail() {
      echo "error: $1" >&2
      exit 1
    }

    get_repo_root() {
      ${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null || fail "Not in a git repository"
    }

    get_worktrees_dir() {
      echo "$(get_repo_root)/.worktrees"
    }

    ensure_gitignore() {
      local repo_root gitignore
      repo_root=$(get_repo_root)
      gitignore="$repo_root/.gitignore"

      if [[ -f "$gitignore" ]]; then
        if ! ${pkgs.gnugrep}/bin/grep -qxF '.worktrees' "$gitignore" 2>/dev/null; then
          echo '.worktrees' >> "$gitignore"
        fi
      else
        echo '.worktrees' > "$gitignore"
      fi
    }

    branch_to_path() {
      echo "$1" | ${pkgs.coreutils}/bin/tr '/' '-'
    }

    list_worktrees() {
      local repo_root
      repo_root=$(get_repo_root)
      ${pkgs.git}/bin/git -C "$repo_root" worktree list --porcelain
    }

    find_worktree_by_branch() {
      local branch="$1"
      local repo_root
      repo_root=$(get_repo_root)

      ${pkgs.git}/bin/git -C "$repo_root" worktree list --porcelain | ${pkgs.gawk}/bin/awk -v branch="$branch" '
        /^worktree / { path = substr($0, 10) }
        /^branch / {
          b = substr($0, 8)
          gsub(/^refs\/heads\//, "", b)
          if (b == branch) { print path; exit }
        }
      '
    }

    find_worktree_by_path() {
      local target="$1"
      local repo_root
      repo_root=$(get_repo_root)

      ${pkgs.git}/bin/git -C "$repo_root" worktree list --porcelain | ${pkgs.gawk}/bin/awk -v target="$target" '
        /^worktree / {
          path = substr($0, 10)
          if (path == target) { print path; exit }
        }
      '
    }

    ref_exists() {
      local repo_root="$1"
      local ref="$2"
      ${pkgs.git}/bin/git -C "$repo_root" rev-parse --verify "$ref" >/dev/null 2>&1
    }

    # ============================================================================
    # Commands
    # ============================================================================

    cmd_new() {
      [[ -z "''${WUT_WRAPPER_ACTIVE:-}" ]] && fail "wut new requires shell integration. Add 'dots.git.wut.enable = true;' to your config."

      local branch="" from_ref="HEAD"

      while [[ $# -gt 0 ]]; do
        case "$1" in
          --from)
            from_ref="$2"
            shift 2
            ;;
          *)
            branch="$1"
            shift
            ;;
        esac
      done

      [[ -z "$branch" ]] && fail "Usage: wut new <branch> [--from <ref>]"

      ensure_gitignore

      local repo_root worktrees_dir worktree_path
      repo_root=$(get_repo_root)
      worktrees_dir=$(get_worktrees_dir)
      worktree_path="$worktrees_dir/$(branch_to_path "$branch")"

      local existing
      existing=$(find_worktree_by_branch "$branch")
      [[ -n "$existing" ]] && fail "Branch '$branch' already has a worktree at $existing"

      if [[ -d "$worktree_path" ]]; then
        local i=1
        while [[ -d "''${worktree_path}-$i" ]]; do
          ((i++))
        done
        worktree_path="''${worktree_path}-$i"
      fi

      ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$worktree_path")"

      local branch_ref="refs/heads/$branch"
      local remote_ref="refs/remotes/origin/$branch"

      if ref_exists "$repo_root" "$branch_ref"; then
        ${pkgs.git}/bin/git -C "$repo_root" worktree add "$worktree_path" "$branch"
      elif ref_exists "$repo_root" "$remote_ref"; then
        ${pkgs.git}/bin/git -C "$repo_root" worktree add -b "$branch" "$worktree_path" "origin/$branch"
      else
        ${pkgs.git}/bin/git -C "$repo_root" worktree add -b "$branch" "$worktree_path" "$from_ref"
      fi

      echo "__WUT_CD__:$worktree_path"
    }

    cmd_list() {
      local repo_root cwd
      repo_root=$(get_repo_root)
      cwd=$(${pkgs.coreutils}/bin/pwd)

      local entries=()
      local current_path=""
      local current_branch=""

      while IFS= read -r line; do
        case "$line" in
          "worktree "*)
            current_path="''${line#worktree }"
            ;;
          "branch "*)
            current_branch="''${line#branch refs/heads/}"
            ;;
          "")
            if [[ -n "$current_path" ]]; then
              entries+=("$current_path|''${current_branch:-(detached)}")
            fi
            current_path=""
            current_branch=""
            ;;
        esac
      done < <(list_worktrees; echo "")

      if [[ ''${#entries[@]} -eq 0 ]]; then
        echo "No worktrees."
        return
      fi

      local current_worktree=""
      for entry in "''${entries[@]}"; do
        local path="''${entry%%|*}"
        if [[ "$cwd" == "$path" || "$cwd" == "$path"/* ]]; then
          if [[ ''${#path} -gt ''${#current_worktree} ]]; then
            current_worktree="$path"
          fi
        fi
      done

      local max_len=0
      for entry in "''${entries[@]}"; do
        local branch="''${entry#*|}"
        if [[ ''${#branch} -gt $max_len ]]; then
          max_len=''${#branch}
        fi
      done

      for entry in "''${entries[@]}"; do
        local path="''${entry%%|*}"
        local branch="''${entry#*|}"
        local icon="🌿"

        if [[ "$path" == "$current_worktree" ]]; then
          icon="👉"
        elif [[ "$path" == "$repo_root" ]]; then
          icon="🏠"
        fi

        local display_path="''${path/#$HOME/~}"
        printf "%s %-''${max_len}s  %s\n" "$icon" "$branch" "$display_path"
      done
    }

    cmd_go() {
      [[ -z "''${WUT_WRAPPER_ACTIVE:-}" ]] && fail "wut go requires shell integration. Add 'dots.wut.enable = true;' to your config."

      ensure_gitignore

      local target=""
      for arg in "$@"; do
        [[ "$arg" != -* ]] && target="$arg"
      done

      local repo_root resolved_path
      repo_root=$(get_repo_root)

      if [[ -z "$target" ]]; then
        resolved_path="$repo_root"
      else
        resolved_path=$(find_worktree_by_branch "$target")
        if [[ -z "$resolved_path" ]]; then
          local abs_target
          abs_target=$(${pkgs.coreutils}/bin/realpath "$target" 2>/dev/null || echo "")
          resolved_path=$(find_worktree_by_path "$abs_target")
        fi
      fi

      [[ -z "$resolved_path" ]] && fail "No worktree found for '$target'."

      echo "__WUT_CD__:$resolved_path"
    }

    cmd_path() {
      [[ $# -lt 1 ]] && fail "Usage: wut path <branch>"

      local branch="$1"
      local path
      path=$(find_worktree_by_branch "$branch")

      [[ -z "$path" ]] && fail "No worktree found for branch '$branch'."

      echo "$path"
    }

    cmd_rm() {
      [[ $# -lt 1 ]] && fail "Usage: wut rm <branch-or-path> [--force]"

      local target="$1"
      shift
      local force=false

      for arg in "$@"; do
        [[ "$arg" == "--force" ]] && force=true
      done

      ensure_gitignore

      local repo_root resolved_path branch_name=""
      repo_root=$(get_repo_root)

      resolved_path=$(find_worktree_by_branch "$target")
      if [[ -n "$resolved_path" ]]; then
        branch_name="$target"
      else
        local abs_target
        abs_target=$(${pkgs.coreutils}/bin/realpath "$target" 2>/dev/null || echo "$target")
        resolved_path=$(find_worktree_by_path "$abs_target")
        if [[ -n "$resolved_path" ]]; then
          branch_name=$(${pkgs.git}/bin/git -C "$repo_root" worktree list --porcelain | ${pkgs.gawk}/bin/awk -v path="$resolved_path" '
            /^worktree / { p = substr($0, 10) }
            /^branch / {
              if (p == path) {
                b = substr($0, 8)
                gsub(/^refs\/heads\//, "", b)
                print b
                exit
              }
            }
          ')
        fi
      fi

      [[ -z "$resolved_path" ]] && fail "No worktree found for '$target'."

      local cwd resolved_abs in_worktree=false
      cwd=$(${pkgs.coreutils}/bin/pwd)
      resolved_abs=$(${pkgs.coreutils}/bin/realpath "$resolved_path")

      [[ "$cwd" == "$resolved_abs" || "$cwd" == "$resolved_abs"/* ]] && in_worktree=true

      if $in_worktree && ! $force; then
        fail "Cannot remove current worktree. Use --force to remove and return to repo root."
      fi

      if $in_worktree && [[ -z "''${WUT_WRAPPER_ACTIVE:-}" ]]; then
        fail "wut rm --force requires shell integration. Add 'dots.git.wut.enable = true;' to your config."
      fi

      if ! $force; then
        local status
        status=$(${pkgs.git}/bin/git -C "$resolved_path" status --porcelain 2>/dev/null || echo "")
        [[ -n "$status" ]] && fail "Worktree has uncommitted changes. Use --force to remove anyway."

        if [[ -n "$branch_name" ]]; then
          local merged
          merged=$(${pkgs.git}/bin/git -C "$repo_root" branch --merged 2>/dev/null || echo "")
          if ! echo "$merged" | ${pkgs.gnugrep}/bin/grep -qE "^[* +]*$branch_name\$"; then
            fail "Branch '$branch_name' is not fully merged. Use --force to remove anyway."
          fi
        fi
      fi

      local git_args=("worktree" "remove")
      $force && git_args+=("--force")
      git_args+=("$resolved_path")

      ${pkgs.git}/bin/git -C "$repo_root" "''${git_args[@]}"

      if [[ -n "$branch_name" ]]; then
        local delete_flag="-d"
        $force && delete_flag="-D"
        ${pkgs.git}/bin/git -C "$repo_root" branch "$delete_flag" "$branch_name" 2>/dev/null || true
      fi

      if $in_worktree && [[ "$cwd" != "$repo_root" ]]; then
        echo "__WUT_CD__:$repo_root"
      fi
    }

    # ============================================================================
    # Main
    # ============================================================================

    if [[ $# -lt 1 ]]; then
      cat << EOF
    wut? - Worktrees Unexpectedly Tolerable

    Usage: wut <command> [args]

    Commands:
      new <branch>  Create a new worktree for <branch>
      list          List all worktrees
      go [branch]   Go to worktree (or repo root if no branch)
      path <branch> Print path to worktree
      rm <branch>   Remove worktree and delete branch

    Options:
      --help, -h    Show this help
      --version, -V Show version
    EOF
      exit 0
    fi

    cmd="$1"
    shift

    case "$cmd" in
      new)          cmd_new "$@" ;;
      list)         cmd_list ;;
      go)           cmd_go "$@" ;;
      path)         cmd_path "$@" ;;
      rm)           cmd_rm "$@" ;;
      --help|-h)    exec "$0" ;;
      --version|-V) echo "wut $VERSION" ;;
      *)            fail "Unknown command: $cmd" ;;
    esac
  '';

  wut = pkgs.stdenv.mkDerivation {
    pname = "wut";
    version = "0.1.2";

    dontUnpack = true;

    nativeBuildInputs = [
      pkgs.pandoc
      pkgs.installShellFiles
    ];

    manPageSrc = ./wut.1.md;
    bashCompletionSrc = ./completions/wut.bash;
    zshCompletionSrc = ./completions/wut.zsh;
    fishCompletionSrc = ./completions/wut.fish;

    buildPhase = ''
      # Convert markdown man page to man format
      ${pkgs.pandoc}/bin/pandoc -s -t man $manPageSrc -o wut.1
    '';

    installPhase = ''
      mkdir -p $out/bin

      # Install binary
      cp ${wutScript} $out/bin/wut
      chmod +x $out/bin/wut

      # Install man page
      installManPage wut.1

      # Install completions
      installShellCompletion --bash --name wut $bashCompletionSrc
      installShellCompletion --zsh --name _wut $zshCompletionSrc
      installShellCompletion --fish --name wut.fish $fishCompletionSrc
    '';

    meta = with lib; {
      description = "Worktrees Unexpectedly Tolerable - ephemeral Git worktrees without the ceremony";
      homepage = "https://github.com/simonbs/wut";
      license = licenses.mit;
      maintainers = [ ];
    };
  };
in
{
  options.dots.git.wut = {
    enable = lib.mkEnableOption "wut - ephemeral Git worktree management";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ wut ];

    # Shell wrapper function to handle directory changes
    programs.zsh.initContent = ''
      # wut wrapper - intercepts __WUT_CD__ markers to change directories
      wut() {
        export WUT_WRAPPER_ACTIVE=1
        local output
        output=$(${wut}/bin/wut "$@" 2>&1)
        local exit_code=$?
        local cd_marker
        cd_marker=$(echo "$output" | grep "^__WUT_CD__:" | head -1)
        if [ -n "$cd_marker" ]; then
          local target_dir="''${cd_marker#__WUT_CD__:}"
          if [ -d "$target_dir" ]; then
            cd "$target_dir" || return 1
          fi
          local filtered
          filtered=$(printf "%s" "$output" | grep -v "^__WUT_CD__:")
          if [[ -n "''${filtered//[[:space:]]/}" ]]; then
            printf "%s\n" "$filtered"
          fi
        else
          if [[ -n "''${output//[[:space:]]/}" ]]; then
            printf "%s\n" "$output"
          fi
        fi
        return $exit_code
      }
    '';
  };
}
