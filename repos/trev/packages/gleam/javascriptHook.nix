{
  makeSetupHook,
  tomlq,
  gleam,
  nodejs,
  bash,
}:

makeSetupHook {
  name = "gleam-javascript-hook";
  propagatedBuildInputs = [
    tomlq
    gleam
    nodejs
  ];
  substitutions = {
    shell = "${bash}/bin/bash";
    nodejs = "${nodejs}/bin/node";
  };
} ./javascriptHook.sh
