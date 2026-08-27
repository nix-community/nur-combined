# Shared builder for every manboster release channel; each pkgs/manboster*/default.nix
# supplies its own nvfetcher source and gomod2nix lockfile.
{
  lib,
  buildGoApplication,
  libffi,
  stdenv,
  source,
  modules,
  version,
  # `dev` moved the ldflag vars out of `internal/config`.
  releasePkg ? "internal/config",
  # File holding `const Version`, or null to keep upstream's literal.
  versionFile ? "${releasePkg}/version.go",
  channel ?
    if lib.hasInfix "-rc" version
    then "rc"
    else if lib.hasInfix "-beta" version
    then "beta"
    else if lib.hasInfix "-alpha" version
    then "alpha"
    else "stable",
}: let
  ldflagPrefix = "-X github.com/manboster/manboster/${releasePkg}";

  # nixpkgs keeps this unversioned symlink in libffi's default output; see pkgs/by-name/jf/jffi.
  libffiPath = "${lib.getLib libffi}/lib/libffi${stdenv.hostPlatform.extensions.sharedLibrary}";
in
  buildGoApplication {
    inherit (source) pname src;
    inherit version modules;

    subPackages = [
      "cmd/manboster"
      "cmd/manbodev"
    ];

    # Share the CGO setting with gomod2nix's dependency cache.
    CGO_ENABLED = "0";

    # `jupiterrider/ffi` ships a libffi that its own init unpacks into the user cache directory,
    # which both defeats the `-X` below and leaves an unmanaged copy outside the store.
    tags = ["ffi_no_embed"];

    # `Version` is a const, so `-X` cannot reach it; rewrite the literal instead.
    # A silent no-op cannot slip through: installCheckPhase asserts the result.
    postPatch = lib.optionalString (versionFile != null) ''
      sed -i -E 's|^const Version = "[^"]*"$|const Version = "${version}"|' ${versionFile}
    '';

    # Leave BuildTime at its `unknown` default; a timestamp would break reproducibility.
    ldflags = [
      "-s"
      "-w"
      "${ldflagPrefix}.BuildCommit=${source.src.rev}"
      "${ldflagPrefix}.CurrentChannel=${channel}"
      # `jupiterrider/ffi` dlopens libffi from a package init, so a bare soname would resolve only by luck.
      # It looks the name up in a package-level var rather than a const, which is what lets `-X` reach it.
      "-X github.com/jupiterrider/ffi.filename=${libffiPath}"
    ];

    doCheck = true;

    postInstall = ''
      install -Dm644 \
        LICENSE \
        README.md \
        README.zh_CN.md \
        CHANGELOG.md \
        SECURITY.md \
        -t $out/share/doc/${source.pname}
    '';

    doInstallCheck = true;
    installCheckPhase =
      ''
        runHook preInstallCheck

        # `manboster` flocks $MANBOSTER_HOME/.manboster before any subcommand runs.
        export MANBOSTER_HOME="$(mktemp -d)"

        manbosterVersion="$($out/bin/manboster version)"
        manbodevVersion="$($out/bin/manbodev version)"
        echo "$manbosterVersion"
        echo "$manbodevVersion"

        echo "$manbosterVersion" | grep -F 'Manboster version '
        echo "$manbodevVersion" | grep -F 'Manbodev version '
        echo "$manbosterVersion" | grep -F '${channel}, commit ${source.src.rev}'
        echo "$manbodevVersion" | grep -F '${channel}, commit ${source.src.rev}'
      ''
      + lib.optionalString (versionFile != null) ''

        echo "$manbosterVersion" | grep -F 'Manboster version ${version} ${channel}'
        echo "$manbodevVersion" | grep -F 'Manbodev version ${version} ${channel}'
      ''
      + ''

        $out/bin/manboster --help >/dev/null
        $out/bin/manbodev --help >/dev/null

        test -f $out/share/doc/${source.pname}/LICENSE
        test -f $out/share/doc/${source.pname}/README.md

        runHook postInstallCheck
      '';

    meta = {
      description = "Manboster: Your Personal Manbo Lobster";
      homepage = "https://github.com/manboster/manboster";
      changelog =
        if channel == "canary"
        then "https://github.com/manboster/manboster/commits/${source.src.rev}"
        else "https://github.com/manboster/manboster/releases/tag/${source.version}";
      license = lib.licenses.asl20;
      mainProgram = "manboster";
      maintainers = [
        {
          name = "mzwing";
        }
      ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
  }
