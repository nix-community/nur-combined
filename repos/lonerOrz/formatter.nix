{
  writeShellApplication,
  nixfmt,
  shfmt,
  ruff,
  mdformat,
  rustfmt,
  stylua,
  prettier,
  svgo,
  git,
  coreutils,
  findutils,
  diffutils,
}:
writeShellApplication {
  name = "nur-fmt";
  runtimeInputs = [
    nixfmt
    shfmt
    ruff
    mdformat
    rustfmt
    stylua
    prettier
    svgo
    git
    coreutils
    findutils
    diffutils
  ];
  # 注意 Nix `''` 缩进字符串的转义规则：
  #   - bash 空字符串一律写 ""，不能写 ''（'' 是 Nix 字符串结束）
  #   - bash 需要 ${...} 插值时写 ''${...}
  #   - $VAR / "$VAR" / $'\0' / $'\e[..' 不受 Nix 影响，原样保留
  text = ''
    set -euo pipefail

    # 颜色（仅 stderr 是 tty 时启用）
    if [ -t 2 ]; then
      DIM=$'\e[2m'
      RED=$'\e[31m'
      RESET=$'\e[0m'
    else
      DIM=""
      RED=""
      RESET=""
    fi

    info() { printf 'nur-fmt: %s\n' "$*" >&2; }
    err()  { printf 'nur-fmt: %s%s%s\n' "$RED" "$*" "$RESET" >&2; }

    # 扩展名 → 工具名
    classify() {
      case "$1" in
        *.nix)  echo nix ;;
        *.sh)
          # nix-shell scripts may run a non-shell interpreter.
          if head -3 "$1" | grep -q -- '-i python'; then
            echo python
          else
            echo sh
          fi
          ;;
        *.py)   echo python ;;
        *.md)   echo markdown ;;
        *.rs)   echo rust ;;
        *.lua)  echo lua ;;
        *.html|*.js|*.css|*.yaml|*.yml|*.json) echo prettier ;;
        *.svg)  echo svg ;;
        *)      echo "" ;;
      esac
    }

    # 按工具批量格式化（工具均支持多文件参数）
    run_tool() {
      local tool=$1
      shift
      case "$tool" in
        nix)      nixfmt "$@" ;;
        sh)       shfmt -i 2 -ci -bn -w "$@" ;;
        python)   ruff format --silent "$@" ;;
        markdown) mdformat "$@" ;;
        rust)     rustfmt --quiet "$@" ;;
        lua)      stylua "$@" ;;
        prettier) prettier --write "$@" ;;
        svg)      svgo "$@" ;;
        *)        return 127 ;;
      esac
    }

    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT

    tools_seen=()
    skipped=0

    add_file() {
      [ -f "$1" ] || return 0
      local tool
      tool=$(classify "$1")
      if [ -z "$tool" ]; then
        skipped=$((skipped + 1))
        return 0
      fi
      printf '%s\0' "$1" >> "$tmpdir/batch-$tool"
      local seen
      for seen in "''${tools_seen[@]}"; do
        [ "$seen" = "$tool" ] && return 0
      done
      tools_seen+=("$tool")
    }

    if [ $# -gt 0 ]; then
      for f in "$@"; do
        add_file "$f"
      done
    else
      while IFS= read -r -d $'\0' f; do
        add_file "$f"
      done < <(git ls-files -z)
    fi

    # 汇总待处理文件
    declare -a all_files=()
    for tool in "''${tools_seen[@]}"; do
      while IFS= read -r -d $'\0' f; do
        all_files+=("$f")
      done < "$tmpdir/batch-$tool"
    done
    total=''${#all_files[@]}

    if [ "$total" -eq 0 ]; then
      info "0 formatted, $skipped skipped"
      exit 0
    fi

    printf '%s\0' "''${all_files[@]}" \
      | xargs -0 md5sum -- > "$tmpdir/before" 2>/dev/null || true

    ordered_tools=()
    while IFS= read -r t; do
      ordered_tools+=("$t")
    done < <(printf '%s\n' "''${tools_seen[@]}" | sort)

    failed_list=()
    for tool in "''${ordered_tools[@]}"; do
      mapfile -d $'\0' -t files < "$tmpdir/batch-$tool"
      info "$(printf '%-10s %3d files' "$tool" "''${#files[@]}")"
      if ! run_tool "$tool" "''${files[@]}" > /dev/null; then
        # 批量失败时逐文件重试，精确定位失败文件
        for f in "''${files[@]}"; do
          run_tool "$tool" "$f" > /dev/null 2>&1 || failed_list+=("$f")
        done
      fi
    done

    printf '%s\0' "''${all_files[@]}" \
      | xargs -0 md5sum -- > "$tmpdir/after" 2>/dev/null || true

    changed_list=()
    while IFS= read -r line; do
      changed_list+=("''${line#< *  }")
    done < <(diff "$tmpdir/before" "$tmpdir/after" 2>/dev/null | grep '^<' || true)

    printf '\n' >&2
    if [ "''${#changed_list[@]}" -gt 0 ]; then
      printf 'nur-fmt: %schanged (%d):%s\n' \
        "$DIM" "''${#changed_list[@]}" "$RESET" >&2
      for f in "''${changed_list[@]}"; do
        printf '  %s%s%s\n' "$DIM" "$f" "$RESET" >&2
      done
    fi
    if [ "''${#failed_list[@]}" -gt 0 ]; then
      err "failed (''${#failed_list[@]}):"
      for f in "''${failed_list[@]}"; do
        printf '  %s\n' "$f" >&2
      done
    fi

    info "$total formatted, ''${#changed_list[@]} changed, $skipped skipped, ''${#failed_list[@]} failed"

    [ "''${#failed_list[@]}" -eq 0 ]
  '';
}
