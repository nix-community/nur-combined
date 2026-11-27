{
  lib,
  pkgs,
  source,
}: let
  pname = "git-cow";
  inherit (source) src version;

  cargoNix = import ./Cargo.nix {
    inherit pkgs;
    defaultCrateOverrides =
      pkgs.defaultCrateOverrides
      // {
        git-cow = attrs: {
          src = source.src;
        };
      };
  };
in
  cargoNix.rootCrate.build.overrideAttrs (old: {
    # Upstream Cargo.toml stays at 0.1.0, so name it after the tag
    name = "${pname}-${version}";

    postInstall = ''
      install -Dm644 \
        ${src}/LICENSE \
        ${src}/README.md \
        -t $out/share/doc/git-cow
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      grep -F 'usage: git cow add' <<<"$($out/bin/git-cow 2>&1 || true)"
      test -f $out/share/doc/git-cow/LICENSE
      test -f $out/share/doc/git-cow/README.md

      runHook postInstallCheck
    '';

    meta =
      old.meta
      // {
        description = "Git worktrees that share files through copy-on-write clones";
        homepage = "https://github.com/gabrielkoerich/git-cow";
        changelog = "https://github.com/gabrielkoerich/git-cow/releases/tag/v${version}";
        license = lib.licenses.mit;
        mainProgram = "git-cow";
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
  })
