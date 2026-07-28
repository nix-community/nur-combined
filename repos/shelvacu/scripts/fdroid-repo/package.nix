{
  makeVacuPythonScript,
  aapt,
  fdroidserver,
  jdk,
  nix,
}:
makeVacuPythonScript {
  name = "fdroid-repo";
  src = ./script.py;
  pathPkgs = [
    aapt
    fdroidserver
    jdk
    nix
  ];
}
