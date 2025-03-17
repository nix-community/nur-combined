{
  source,
  lib,
  newScope,
  runCommand,
  coreutils,
  mq,
  writeText,
}:

let
  inherit (source) src date;
  plugins = lib.importJSON ./plugins.json;
in
(lib.makeScope newScope (
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
  ) plugins
))
// {
  passthru.generate = import ./generate.nix {
    inherit
      source
      lib
      runCommand
      coreutils
      mq
      writeText
      ;
  };
}
