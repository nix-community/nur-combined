{
  sources,
  version,
  lib,
  stdenvNoCC,
  buildDotnetModule,
  dotnetCorePackages,
  findutils,
  nugetDeps ? ./deps.json,
  buildDir ? "lib/hikariii",
  targetDir ? "usrbin",
}:
stdenvNoCC.mkDerivation (final: {
  inherit (sources) pname src;
  inherit version;

  dontUnpack = true;

  dotnetPackage = buildDotnetModule {
    inherit (final) pname src version;

    projectFile = "BuildHikariii/BuildHikariii.csproj";
    inherit nugetDeps;

    dotnet-sdk = dotnetCorePackages.sdk_8_0;
    dotnet-runtime = dotnetCorePackages.runtime_8_0;
  };
  passthru.dotnetPackage = final.dotnetPackage;

  nativeBuildInputs = [ findutils ];

  installPhase =
    let
      buildDir' = "${final.dotnetPackage}/${buildDir}";
    in
    ''
      runHook preInstall

      mkdir -p $out/${targetDir}

      find ${buildDir'} -type f -name "M.*.dll" | while read -r file; do
        rel_path="''${file#${buildDir'}/}"
        dest_path="$out/${targetDir}/$rel_path"
        mkdir -p "$(dirname "$dest_path")"
        install -D "$file" "$dest_path"  
      done

      install -D "${buildDir'}/osu.Game.Rulesets."*.dll "$out/${targetDir}" || true
      install -D "${buildDir'}/Tmds."*.dll "$out/${targetDir}" || true
      install -D "${buildDir'}/NetCoreServ"*.dll "$out/${targetDir}" || true

      runHook postInstall
    '';

  meta = {
    description = "Download booster and in-game music player for Osu! lazer";
    homepage = "https://github.com/hihkm/DanmakuFactory";
    license = lib.licenses.mit;
  };
})
