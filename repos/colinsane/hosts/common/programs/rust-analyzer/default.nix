{ ... }:
{
  sane.programs.rust-analyzer = {
    buildCost = 2;
    sandbox.whitelistPwd = true;
    suggestedPrograms = [
      "cargo"
      "rustc"
    ];
  };
}
