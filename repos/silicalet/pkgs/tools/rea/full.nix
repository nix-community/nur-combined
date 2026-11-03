{
  lib,
  buildEnv,
  rea,
  reaDependencies,
}:

buildEnv {
  name = "rea-full-${rea.version}";
  paths = [ rea ] ++ reaDependencies.all;
  pathsToLink = [
    "/bin"
    "/share/applications"
    "/share/icons"
    "/share/man"
  ];
  meta = {
    inherit (rea.meta)
      homepage
      license
      mainProgram
      platforms
      ;
    description = "REA with analysis tools available on PATH";
  };
}
