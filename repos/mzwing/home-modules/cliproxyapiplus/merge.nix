{pkgs}:
pkgs.writeShellApplication {
  name = "cliproxyapiplus-merge-config";

  runtimeInputs = [
    pkgs.coreutils
    pkgs.jq
    pkgs.yq-go
  ];

  text = ''
    if (( $# < 2 || $# > 3 )); then
      echo "usage: cliproxyapiplus-merge-config CONFIG_FILE MANAGED_FILE [API_KEYS_FILE]" >&2
      exit 2
    fi

    config_file=$1
    managed_file=$2
    api_keys_file=''${3:-}
    config_dir="$(dirname -- "$config_file")"

    umask 077
    mkdir -p -- "$config_dir"

    if [[ -L "$config_file" ]]; then
      echo "cliproxyapiplus: refusing to replace symlink: $config_file" >&2
      exit 1
    fi
    if [[ -e "$config_file" && ! -f "$config_file" ]]; then
      echo "cliproxyapiplus: config path is not a regular file: $config_file" >&2
      exit 1
    fi
    if [[ ! -r "$managed_file" ]]; then
      echo "cliproxyapiplus: managed settings file is not readable: $managed_file" >&2
      exit 1
    fi
    if ! yq eval --exit-status 'tag == "!!map"' "$managed_file" >/dev/null; then
      echo "cliproxyapiplus: managed settings must be a YAML mapping" >&2
      exit 1
    fi

    merged_file="$(mktemp "$config_dir/.config.yaml.merged.XXXXXX")"
    base_file=""
    keys_json=""
    keys_overlay=""

    cleanup() {
      rm -f -- "$merged_file"
      [[ -z "$base_file" ]] || rm -f -- "$base_file"
      [[ -z "$keys_json" ]] || rm -f -- "$keys_json"
      [[ -z "$keys_overlay" ]] || rm -f -- "$keys_overlay"
    }
    trap cleanup EXIT

    if [[ -e "$config_file" ]]; then
      if ! yq eval --exit-status 'tag == "!!map"' "$config_file" >/dev/null; then
        echo "cliproxyapiplus: runtime config must be a YAML mapping: $config_file" >&2
        exit 1
      fi
      runtime_input=$config_file
    else
      base_file="$(mktemp "$config_dir/.config.yaml.base.XXXXXX")"
      printf '{}\n' >"$base_file"
      runtime_input=$base_file
    fi

    merge_inputs=("$runtime_input" "$managed_file")

    if [[ -n "$api_keys_file" ]]; then
      if [[ ! -f "$api_keys_file" || ! -r "$api_keys_file" ]]; then
        echo "cliproxyapiplus: API keys file is not a readable regular file: $api_keys_file" >&2
        exit 1
      fi

      keys_json="$(mktemp "$config_dir/.config.yaml.keys.XXXXXX")"
      if ! yq eval --output-format=json '.' "$api_keys_file" >"$keys_json"; then
        echo "cliproxyapiplus: API keys file is not valid YAML or JSON: $api_keys_file" >&2
        exit 1
      fi
      if ! jq --exit-status \
        'type == "array" and length > 0 and all(.[]; type == "string" and length > 0)' \
        "$keys_json" >/dev/null; then
        echo "cliproxyapiplus: API keys file must contain a non-empty sequence of non-empty strings" >&2
        exit 1
      fi

      keys_overlay="$(mktemp "$config_dir/.config.yaml.keys-overlay.XXXXXX")"
      jq '{"api-keys": .}' "$keys_json" >"$keys_overlay"
      merge_inputs+=("$keys_overlay")
    fi

    if ! yq eval-all \
      '. as $item ireduce ({}; . * $item)' \
      "''${merge_inputs[@]}" >"$merged_file"; then
      echo "cliproxyapiplus: failed to merge configuration" >&2
      exit 1
    fi
    if ! yq eval --exit-status 'tag == "!!map"' "$merged_file" >/dev/null; then
      echo "cliproxyapiplus: merged configuration is not a YAML mapping" >&2
      exit 1
    fi

    chmod 0600 "$merged_file"
    if [[ -e "$config_file" ]] && cmp --silent "$merged_file" "$config_file"; then
      chmod 0600 "$config_file"
    else
      mv -f -- "$merged_file" "$config_file"
    fi
  '';
}
