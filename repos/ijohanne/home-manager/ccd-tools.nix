{ config, lib, pkgs, ... }:
let
  cfg = config.programs.ccd-tools;
  wrappedPackage = pkgs.symlinkJoin {
    name = "ccd-tools-configured";
    paths = [ cfg.package ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for program in "$out"/bin/*; do
        wrapProgram "$program" \
          --set-default CCD_TOOLS_ACCOUNTS ${lib.escapeShellArg cfg.accountsFile}
      done
    '';
    meta.mainProgram = cfg.package.meta.mainProgram or "ccd-status";
  };
in
{
  options.programs.ccd-tools = {
    enable = lib.mkEnableOption "Concordium account tools";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/ccd-tools { };
      defaultText = lib.literalExpression "pkgs.callPackage ../pkgs/ccd-tools { }";
      description = "The ccd-tools package to wrap.";
    };
    accountsFile = lib.mkOption {
      type = lib.types.str;
      example = lib.literalExpression ''config.sops.secrets."ccd-accounts".path'';
      description = ''
        Runtime path to a CSV file containing Name,Address records. Use a string
        such as a decrypted sops-nix secret path; the contents are never copied
        into the Nix store. Applies to every binary in the package. An explicit
        --accounts argument or CCD_TOOLS_ACCOUNTS environment variable overrides it.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ wrappedPackage ];
  };
}
