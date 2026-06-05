{ ... }:
{
  sane.programs.marksman = {
    buildCost = 1;  # dotnet-sdk
    sandbox.whitelistPwd = true;
    sandbox.extraHomePaths = [
      # it needs to work out of the project root to be effective.
      # see ~/.local/state/nvim/lsp.log
      "knowledge"
      "nixos"
    ];
  };
}
