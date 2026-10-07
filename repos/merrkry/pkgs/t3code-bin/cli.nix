{
  git,
  gh,
  mkT3code,
  unwrapped,
  providerPackages,
}:

mkT3code {
  pname = "t3code-bin";
  inherit unwrapped providerPackages;
  runtimePackages = [
    git
    gh
  ]
  ++ providerPackages;
  extraWrapperArgs = "";
  extraInstallCommands = "";
  passthru = { };
}
