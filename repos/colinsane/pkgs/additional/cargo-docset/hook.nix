{ makeSetupHook
, cargo
, cargo-docset
}:
makeSetupHook {
  name = "cargo-docset-hook";
  propagatedBuildInputs = [
    cargo cargo-docset
  ];
} ./hook.sh
