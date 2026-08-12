# Test for ./landlockConfigFromClosure.nix.
#
# Checks the generated configuration three ways: it validates against the
# schema `llconfig` itself reports, it describes exactly the requested closure,
# and it actually sandboxes a process when enforced.
{
  runCommand,
  check-jsonschema,
  closureInfo,
  jq,
  coreutils,
  hello,
  landlockconfig,
  landlockConfigFromClosure,
}:
let
  # Defaults only.
  defaultConfig = landlockConfigFromClosure { name = "default"; } [ hello ];

  # Every option set to something other than its default.
  customConfig = landlockConfigFromClosure {
    name = "custom";
    abi = 6;
    allowedAccess = [
      "read_file"
      "read_dir"
    ];
    baseConfig = {
      ruleset = [ { handledAccessFs = [ "abi.all" ]; } ];
      pathBeneath = [
        {
          allowedAccess = [ "abi.read_write" ];
          parent = [ "/tmp" ];
        }
      ];
    };
  } [ hello ];

  # Handle every filesystem access right, so that anything outside of the
  # closure is denied rather than merely ungranted.
  enforcedConfig = landlockConfigFromClosure {
    name = "enforced";
    baseConfig.ruleset = [ { handledAccessFs = [ "abi.all" ]; } ];
  } [ coreutils ];

  helloClosure = closureInfo { rootPaths = [ hello ]; };
in
runCommand "landlock-config-from-closure-test"
  {
    nativeBuildInputs = [
      check-jsonschema
      jq
      landlockconfig
    ];
  }
  ''
    set -euo pipefail

    failures=0
    ok() { echo "ok: $1"; }
    fail() {
      echo "FAIL: $1" >&2
      failures=$((failures + 1))
    }
    check() {
      local desc=$1 filter=$2 file=$3
      if jq -e "$filter" "$file" > /dev/null; then
        ok "$desc"
      else
        fail "$desc"
        jq . "$file" >&2
      fi
    }

    echo "=== generated configurations validate against 'llconfig schema'"
    llconfig schema > schema.json
    for config in ${defaultConfig} ${customConfig} ${enforcedConfig}; do
      if check-jsonschema --schemafile schema.json "$config"; then
        ok "$config matches the schema"
      else
        fail "$config does not match the schema"
      fi
    done

    echo "=== defaults"
    check "abi defaults to 5" '.abi == 5' ${defaultConfig}
    check "a single pathBeneath rule is generated" \
      '(.pathBeneath | length) == 1' ${defaultConfig}
    check "access defaults to abi.read_execute" \
      '.pathBeneath[0].allowedAccess == ["abi.read_execute"]' ${defaultConfig}
    check "nothing else is declared" \
      'keys == ["abi", "pathBeneath"]' ${defaultConfig}

    echo "=== the rule covers exactly the closure of the root paths"
    jq -r '.pathBeneath[0].parent[]' ${defaultConfig} | sort > got-paths
    sort ${helloClosure}/store-paths > want-paths
    if diff -u want-paths got-paths; then
      ok "parent lists every store path of the closure, and nothing more"
    else
      fail "parent does not match the closure"
    fi
    if grep -qx '${hello}' got-paths; then
      ok "the root path itself is included"
    else
      fail "the root path itself is missing"
    fi

    echo "=== options"
    check "abi is overridable" '.abi == 6' ${customConfig}
    check "allowedAccess is overridable" \
      '.pathBeneath[1].allowedAccess == ["read_file", "read_dir"]' ${customConfig}
    check "baseConfig.ruleset is preserved" \
      '.ruleset == [{"handledAccessFs": ["abi.all"]}]' ${customConfig}
    check "baseConfig.pathBeneath is preserved, closure rule appended" \
      '(.pathBeneath | length) == 2
       and .pathBeneath[0] == {"allowedAccess": ["abi.read_write"], "parent": ["/tmp"]}' \
      ${customConfig}
    case "$(basename ${defaultConfig})" in
      *-landlock-closure-config-default.json) ok "name is used in the derivation name" ;;
      *) fail "name is not used in the derivation name" ;;
    esac

    echo "=== enforcement"
    # The closure of coreutils is granted; ${hello} is not part of it.
    if llconfig run --json ${enforcedConfig} -- true 2> enforce.log; then
      if llconfig run --json ${enforcedConfig} -- ls ${coreutils}/bin > /dev/null; then
        ok "the closure is reachable from inside the sandbox"
      else
        fail "the closure is not reachable from inside the sandbox"
      fi
      if llconfig run --json ${enforcedConfig} -- ls ${hello}/bin > /dev/null 2>&1; then
        fail "a path outside of the closure is reachable from inside the sandbox"
      else
        ok "a path outside of the closure is denied"
      fi
    elif grep -q "can be enforced with the running kernel" enforce.log; then
      echo "SKIP: this kernel has no usable Landlock support" >&2
      cat enforce.log >&2
    else
      fail "the generated configuration could not be enforced"
      cat enforce.log >&2
    fi

    if [ "$failures" -ne 0 ]; then
      echo "$failures check(s) failed" >&2
      exit 1
    fi
    echo "all checks passed" > $out
  ''
