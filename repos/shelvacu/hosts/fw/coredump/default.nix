{
  config,
  lib,
  pkgs,
  ...
}:
let
  filter = pkgs.pkgsStatic.stdenv.mkDerivation {
    name = "cdf";
    src = ./coredump-filter.c;
    dontUnpack = true;
    strictDeps = true;

    buildPhase = ''
      runHook preBuild
      $CC \
        -std=c17 \
        -D_POSIX_C_SOURCE=200809L \
        -DSYSTEMD_COREDUMP='"${config.systemd.package}/lib/systemd/systemd-coredump"' \
        -Wall -Wextra -Werror -Os -static \
        "$src" -o cdf
      runHook postBuild
    '';

    doCheck = true;
    checkPhase = ''
      runHook preCheck

      $CC \
        -std=c17 \
        -D_POSIX_C_SOURCE=200809L \
        -DSYSTEMD_COREDUMP='"${pkgs.coreutils}/bin/false"' \
        -Wall -Wextra -Werror -Os -static \
        "$src" -o cdf-test

      expectStatus() {
        local expected="$1"
        shift
        local actual=0
        "$@" || actual="$?"
        if [[ "$actual" != "$expected" ]]; then
          printf 'expected exit status %s, received %s: %s\n' \
            "$expected" "$actual" "$*" >&2
          return 1
        fi
      }

      systemdArgs=(P u g s t c h d F)
      expectStatus 0 ./cdf-test 3 '!proton!wine-preloader' "''${systemdArgs[@]}"
      expectStatus 1 ./cdf-test 11 '!proton!wine-preloader' "''${systemdArgs[@]}"
      expectStatus 1 ./cdf-test 3 '!proton!wine64-preloader' "''${systemdArgs[@]}"
      expectStatus 64 ./cdf-test

      runHook postCheck
    '';

    installPhase = ''
      runHook preInstall
      install -D -m 0555 cdf "$out/bin/cdf"
      runHook postInstall
    '';

    meta.mainProgram = "cdf";
  };
  # Keep the core_pattern comfortably below the 127-character limit present
  # in older kernels. pkgsStatic adds the target triple to output names.
  filterLink = pkgs.symlinkJoin {
    name = "cdf";
    paths = [ filter ];
  };

  overrideName = "99-wine-coredump-filter.conf";
  expectedPattern = "|${filterLink}/bin/cdf %s %E %P %u %g %s %t %c %h %d %F";
  expectedAssignment = "kernel.core_pattern=${expectedPattern}";
  expectedOverride = "${expectedAssignment}\n";
in
{
  environment.etc."sysctl.d/${overrideName}".text = expectedOverride;

  assertions = [
    {
      assertion = config.systemd.coredump.enable;
      message = "the Wine coredump filter requires systemd-coredump to remain enabled";
    }
    {
      assertion = config.environment.etc."sysctl.d/${overrideName}".text == expectedOverride;
      message = "${overrideName} must set kernel.core_pattern to the Wine coredump filter";
    }
    {
      # Older kernels silently truncate core_pattern at 127 characters.
      assertion = builtins.stringLength expectedPattern <= 127;
      message = "the Wine coredump filter's kernel.core_pattern exceeds 127 characters";
    }
  ];

  system.systemBuilderCommands = ''
    mapfile -t corePatternAssignments < <(
      grep -H -E '^kernel[./]core_pattern[[:space:]]*=' "$out/etc/sysctl.d/"*.conf || true
    )

    if (( ''${#corePatternAssignments[@]} != 2 )); then
      printf 'expected exactly two kernel.core_pattern assignments, found %d:\n' \
        "''${#corePatternAssignments[@]}" >&2
      printf '  %s\n' "''${corePatternAssignments[@]}" >&2
      exit 1
    fi

    mapfile -t corePatternFiles < <(
      printf '%s\n' "''${corePatternAssignments[@]}" \
        | cut -d: -f1 \
        | xargs -n1 basename \
        | sort
    )
    expectedCorePatternFiles=(50-coredump.conf ${overrideName})

    if [[ "''${corePatternFiles[*]}" != "''${expectedCorePatternFiles[*]}" ]]; then
      printf 'unexpected kernel.core_pattern sources: %s\n' \
        "''${corePatternFiles[*]}" >&2
      exit 1
    fi

    if ! grep -Fqx ${lib.escapeShellArg expectedAssignment} \
      "$out/etc/sysctl.d/${overrideName}"; then
      echo '${overrideName} does not contain the expected kernel.core_pattern' >&2
      exit 1
    fi
  '';
}
