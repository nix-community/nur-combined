{ makeSetupHook
, cargo-docset
}:
makeSetupHook {
  name = "cargo-docset-hook";
  propagatedBuildInputs = [
    cargo-docset
  ];
} ./hook.sh
