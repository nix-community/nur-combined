
reset_color=""
info_color=""
success_color=""
error_color=""
if colors=$(tput colors 2> /dev/null); then
    if [ "$colors" -ge 256 ]; then
        reset_color=$(tput sgr0)
        info_color=$(tput setaf 189)
        success_color=$(tput setaf 117)
        error_color=$(tput setaf 211)
    fi
fi

function info {
    printf "%s%s%s\n" "${info_color}" "$1" "$reset_color"
}

function success {
    printf "\n%s%s%s\n" "${success_color}" "$1" "$reset_color"
    exit 0
}

function error {
    printf "\n%s%s%s\n" "${error_color}" "$1" "$reset_color"
    exit 1
}

path=$(dirname "${1:-.}")
if [[ ! -d "$path" ]]; then
    error "directory $path does not exist"
elif [[ ! -f "$path/flake.nix" ]]; then
    error "file $path/flake.nix does not exist"
fi

if out=$(nix build "${1:-.}" --no-link 2>&1); then
    success "build successful, no hash mismatch found"
elif [[ ! "$out" =~ "hash mismatch" ]]; then
    error "build failed, but no hash mismatch found"
fi

old_hash=""
if [[ $out =~ specified:[[:space:]]+([^[:space:]]+) ]]; then
    old_hash="${BASH_REMATCH[1]}"
else
    error "could not extract old hash"
fi
if [[ -z "$old_hash" ]]; then
    error "no old hash found"
fi
info "old hash: $old_hash"

new_hash=""
if [[ $out =~ got:[[:space:]]+([^[:space:]]+) ]]; then
    new_hash="${BASH_REMATCH[1]}"
else
    error "could not extract new hash"
fi
if [[ -z "$new_hash" ]]; then
    error "no new hash found"
fi
info "new hash: $new_hash"

if ! sed -i -e "s|${old_hash}|${new_hash}|g" "$path/flake.nix"; then
    error "failed to update hash in $path"
fi

success "updated hash in $path/flake.nix"