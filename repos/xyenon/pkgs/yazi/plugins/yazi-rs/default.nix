{
  source,
  lib,
  newScope,
  runCommand,
  writeText,
}:

let
  inherit (source) src date;
  plugins = lib.importJSON ./plugins.json;
  scope =
    self:
    lib.mapAttrs (
      name: value:
      (self.callPackage (
        {
          lib,
          stdenvNoCC,
          src,
        }:
        stdenvNoCC.mkDerivation {
          pname = name;
          version = "0-unstable-${date}";

          inherit src;

          dontBuild = true;

          installPhase = ''
            runHook preInstall

            cp -rL '${name}.yazi' $out

            runHook postInstall
          '';

          meta = with lib; {
            inherit (value) description;
            homepage = "https://github.com/yazi-rs/plugins/tree/main/${name}.yazi";
            license = licenses.mit;
            maintainers = with maintainers; [ xyenon ];
          };
        }
      ) { inherit src; })
    ) plugins;
in

with lib;
(pipe scope [
  (makeScope newScope)
  recurseIntoAttrs
])
// {
  passthru.generate = import ./generate.nix {
    inherit
      source
      lib
      runCommand
      writeText
      ;
  };
}
