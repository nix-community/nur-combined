{
  makeSetupHook,
  tomlq,
  gleam,
  erlang,
  rebar3,
  bash,
}:

makeSetupHook {
  name = "gleam-erlang-hook";
  propagatedBuildInputs = [
    tomlq
    gleam
    erlang
    rebar3
  ];
  substitutions = {
    shell = "${bash}/bin/bash";
    erl = "${erlang}/bin/erl";
  };
} ./erlangHook.sh
