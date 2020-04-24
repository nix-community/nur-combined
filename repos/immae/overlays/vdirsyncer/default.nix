self: super: {
  vdirsyncer = super.vdirsyncer.overridePythonAttrs(old: {
    # https://github.com/NixOS/nixpkgs/pull/85809
    postPatch = old.postPatch + ''
      sed -i "s/invalid value for \"--verbosity\"/invalid value for \\\'--verbosity\\\'/" tests/system/cli/test_sync.py
    '';
  });
  khal = super.khal.overridePythonAttrs(old: {
    postPatch = ''
      sed -i "s/Invalid value for \"ics\"/Invalid value for \\\'ics\\\'/" tests/cli_test.py
      sed -i "s/Invalid value for \"\[ICS\]\"/Invalid value for \\\'[ICS]\\\'/" tests/cli_test.py
    '';
  });
}
