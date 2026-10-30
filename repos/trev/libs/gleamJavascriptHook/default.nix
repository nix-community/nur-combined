{
  concatText,
  makeSetupHook,
  tomlq,
  gleam,
  nodejs,
  bash,
}:

makeSetupHook
  {
    name = "gleam-javascript-hook";
    propagatedBuildInputs = [
      tomlq
      gleam
      nodejs
    ];
    substitutions = {
      gleamTarget = "javascript";
      shell = "${bash}/bin/bash";
      nodejs = "${nodejs}/bin/node";
    };
  }
  (
    concatText "gleam-javascript-hook.sh" [
      ../gleamHook/gleamHook.sh
      ./javascriptHook.sh
    ]
  )
