{
  bash,
  beamMinimalPackages,
  concatText,
  gleam,
  makeSetupHook,
  rebar3,
  tomlq,
}:

makeSetupHook
  {
    name = "gleam-erlang-hook";
    propagatedBuildInputs = [
      beamMinimalPackages.erlang
      rebar3
      tomlq

      # avoid deno https://github.com/NixOS/nixpkgs/issues/511900
      (gleam.overrideAttrs {
        nativeCheckInputs = [ ];
        doCheck = false;
      })
    ];
    substitutions = {
      gleamTarget = "erlang";
      shell = "${bash}/bin/bash";
      erl = "${beamMinimalPackages.erlang}/bin/erl";
    };
  }
  (
    concatText "gleam-erlang-hook.sh" [
      ../gleamHook/gleamHook.sh
      ./erlangHook.sh
    ]
  )
