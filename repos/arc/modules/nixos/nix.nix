{ pkgs, config, lib, ... }: with lib; let
  cfg = config.nix;
  accessTokens = mapAttrsToList (key: value:
    "${key}=${value}"
  ) cfg.accessTokens;
  accessTokensStr = concatStringsSep " " accessTokens;
  experimentalFeatures = concatStringsSep " " cfg.experimentalFeatures;
in {
  options.nix = {
    accessTokens = mkOption {
      type = with types; attrsOf str;
      default = { };
      example = {
        "github.com" = "23ac...b289";
      };
    };
    isNix24 = mkOption {
      type = types.bool;
      default = versionAtLeast cfg.package.version "2.4";
      readOnly = true;
    };
    nix24 = {
      package = mkOption {
        type = types.package;
        default = pkgs.nix_2_4;
      };
      wrapped = mkOption {
        type = types.package;
        default = pkgs.runCommand "nix24" {
          passAsFile = [ "script" ];
          script = ''
            #!@runtimeShell@
            set -eu

            if [[ ! $PATH = @out@/bin:* ]]; then
              export PATH="@out@/bin:$PATH"
            fi
            exec @nix@/bin/nix \
              --extra-experimental-features ${escapeShellArg experimentalFeatures} \
              --access-tokens ${escapeShellArg accessTokensStr} \
              "$@"
          '';
          inherit (pkgs) runtimeShell;
          nix = cfg.nix24.package;
        } ''
          mkdir -p $out/bin
          substituteAll $scriptPath $out/bin/nix
          chmod +x $out/bin/nix
        '';
        readOnly = true;
      };
    };
    experimentalFeatures = mkOption {
      type = with types; listOf (enum [ "nix-command" "flakes" "ca-derivations" "impure-derivations" "recursive-nix" "no-url-literals" ]);
      default = [ ];
    };
  };
  config.nix.settings = {
    access-tokens = mkIf (cfg.isNix24 && cfg.accessTokens != { }) accessTokens;
    experimental-features = mkIf (cfg.isNix24 && cfg.experimentalFeatures != [ ]) cfg.experimentalFeatures;
  };
}
