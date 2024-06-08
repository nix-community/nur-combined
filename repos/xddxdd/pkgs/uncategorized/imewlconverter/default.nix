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

  meta = with lib; {
    description = "”深蓝词库转换“ 一款开源免费的输入法词库转换程序";
    homepage = "https://github.com/studyzy/imewlconverter";
    maintainers = with maintainers; [ xddxdd ];
    license = licenses.gpl3Only;
  };
}
