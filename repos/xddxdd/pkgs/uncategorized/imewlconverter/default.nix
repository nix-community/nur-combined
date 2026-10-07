{
  fetchFromGitHub,
  lib,
  git,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
}:

buildDotnetModule (finalAttrs: {
  pname = "imewlconverter";
  version = "3.5.0";
  src = fetchFromGitHub {
    owner = "studyzy";
    repo = "imewlconverter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PE1dAJiFHqrpE8ceCrCfSu7QwZsa4fgyJ5fW5UNsihI=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  projectFile = "src/ImeWlConverterCmd/ImeWlConverterCmd.csproj";
  nugetDeps = ./deps.json;

  nativeBuildInputs = [ git ];

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/studyzy/imewlconverter/releases/tag/v${finalAttrs.version}";
    mainProgram = "ImeWlConverterCmd";
    description = "FOSS program for converting IME dictionaries";
    homepage = "https://github.com/studyzy/imewlconverter";
    maintainers = with lib.maintainers; [ xddxdd ];
    license = lib.licenses.gpl3Only;
  };
})
