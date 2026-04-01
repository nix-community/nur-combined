{
  bash,
  beamMinimalPackages,
  gleam,
  makeSetupHook,
  rebar3,
  tomlq,
}:

makeSetupHook {
  name = "gleam-erlang-hook";
  propagatedBuildInputs = [
    beamMinimalPackages.erlang
    gleam
    rebar3
    tomlq
  ];
  substitutions = {
    shell = "${bash}/bin/bash";
    erl = "${beamMinimalPackages.erlang}/bin/erl";
  };
} ./erlangHook.sh
