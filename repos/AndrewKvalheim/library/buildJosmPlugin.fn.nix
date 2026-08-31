{ lib
, stdenvNoCC

  # Dependencies
, ant
, jdk
, josm-plugin-build-env
}:

let
  inherit (lib) extendMkDerivation;
in
extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;

  excludeDrvArgNames = [ "pluginName" ];

  extendDrvArgs = _: { pluginName ? args.pname, ... } @ args: {
    unpackPhase = ''
      cp --no-preserve=mode --recursive ${josm-plugin-build-env}/* './'
      cp --no-preserve=mode --recursive "$src" 'plugins/${pluginName}'
    '';

    nativeBuildInputs = [ ant jdk ];
    buildPhase = ''
      runHook preBuild
      env --chdir 'plugins/${pluginName}' ant
      runHook postBuild
    '';

    installPhase = ''
      install -D --target-directory "$out/share/JOSM/plugins" 'dist/${pluginName}.jar'
    '';
  };
}
