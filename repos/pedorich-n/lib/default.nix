{
  lib
}:
{

  modulesFromDirectoryRecursive =
    {
      directory,
      fileName ? "module.nix",
    }:
    let
      processDir =
        dir:
        lib.concatMapAttrs (
          name: type:
          let
            path = dir + "/${name}";
          in
          if type == "directory" then
            let
              modulePath = path + "/${fileName}";
            in
            if builtins.pathExists modulePath then { ${name} = modulePath; } else { ${name} = processDir path; }
          else
            { }
        ) (builtins.readDir dir);
    in
    processDir directory;
}
