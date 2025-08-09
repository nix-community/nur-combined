{
  proton ? proton-ge-bin,
  proton-ge-bin,
  umu-launcher,
  writeShellApplication,
}:
writeShellApplication {
  name = "umu-run";

  runtimeInputs = [ umu-launcher ];

  runtimeEnv = {
    PROTONPATH = proton.steamcompattool;
  };

  text = ''
    umu-run "$@"
  '';

  derivationArgs = {
    name = "umu-launcher-wrapper";
    preferLocalBuild = true;
  };

  meta = {
    description = "Wrapper for umu-launcher with `PROTONPATH` set to run Proton games";
  };
}
