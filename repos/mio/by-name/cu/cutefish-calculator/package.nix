{ mkCutefishDerivation, cutefish-toolkit }:

mkCutefishDerivation {
  pname = "cutefish-calculator";

  extraBuildInputs = [ cutefish-toolkit ];

  meta = {
    description = "Calculator for the Cutefish desktop";
    mainProgram = "cutefish-calculator";
  };
}
