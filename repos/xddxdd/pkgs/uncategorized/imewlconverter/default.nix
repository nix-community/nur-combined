{
  sources,
  lib,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule {
  inherit (sources.imewlconverter) pname version src;

  projectFile = "src/ImeWlConverterCmd/ImeWlConverterCmd.csproj";
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

  meta = {
    mainProgram = "ImeWlConverterCmd";
    description = "FOSS program for converting IME dictionaries";
    homepage = "https://github.com/studyzy/imewlconverter";
    maintainers = with lib.maintainers; [ xddxdd ];
    license = lib.licenses.gpl3Only;
  };
}
