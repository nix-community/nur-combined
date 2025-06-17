{
  source,
  lib,
  stdenvNoCC,
  undmg,
  config,
  sourceRoot,
  writeText,
  ...
}:
let policies = {
DisableAppUpdate = true;
DisableTelemetry = true;
} // config.zen.policies or {};
policiesJson = writeText "policies.json" (builtins.toJSON { inherit policies;});
in
stdenvNoCC.mkDerivation {
  inherit (source) pname version src;
  inherit sourceRoot;


  nativeBuildInputs = [ undmg ];

  preferLocalBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications/${sourceRoot}
    cp -r . $out/Applications/${sourceRoot}
	mkdir -p "$out/Applications/${sourceRoot}/Contents/Resources/distribution"
	cp ${policiesJson} "$out/Applications/${sourceRoot}/Contents/Resources/distribution/policies.json"


    runHook postInstall
  '';

  meta = {
    description = "Privacy-focused browser that blocks trackers; ads; and other unwanted content while offering the best browsing experience!";
    homepage = "https://github.com/zen-browser/desktop";
    license = lib.licenses.mpl20;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
