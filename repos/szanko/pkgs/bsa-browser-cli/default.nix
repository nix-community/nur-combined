{ lib
, buildDotnetModule
, fetchFromGitHub
, dotnet-sdk_8
, dotnetCorePackages
}:

buildDotnetModule (finalAttrs:  {
  pname = "bsa-browser-cli";
  version = "2025.10.05";

  src = fetchFromGitHub {
    owner = "N3oRay";
    repo = "BSA_Browser";
    rev = "c5bdf6ef36c08ce4b237471fc5af5fd82915fa9a";
    hash = "sha256-ve5aLeQb9LNp1RN0SCNCAcCehjibHug3fAWBbYKEnpY=";
  };

  dotnet-sdk = dotnet-sdk_8;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  projectFile = "BSA_Browser_CLI/BSA_Browser_CLI.csproj";
  nugetDeps = ./deps.json;

  postPatch = ''
    #find . -name '*.csproj' -print0 | xargs -0 sed -i \
    #-e 's#<TargetFramework>net48</TargetFramework>#<TargetFramework>net8.0</TargetFramework>#' \
    #-e 's#<TargetFrameworks>net48;#<TargetFrameworks>net8.0;#g'

    # Normalize the CLI project path to be space-free
    mkdir -p BSA_Browser_CLI
    cp -r "BSA Browser CLI"/. BSA_Browser_CLI/
    rm -rf "BSA Browser CLI"

    # Also rename the csproj so it has no spaces
    mv "BSA_Browser_CLI/BSA Browser CLI.csproj" BSA_Browser_CLI/BSA_Browser_CLI.csproj
  '';

  #packNupkg = true;
  dotnetFlags = [ 
    "-p:SelfContained=false" 
    "-p:RuntimeIdentifier=" 
  ];

  meta = {
    description = "Bethesda Archive Browser & Extractor";
    homepage = "https://github.com/N3oRay/BSA_Browser";
    changelog = "https://github.com/N3oRay/BSA_Browser/blob/${finalAttrs.src.rev}/CHANGELOG.txt";
    license = lib.licenses.gpl3Only;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    mainProgram = "BSA_Browser_CLI";
    platforms = lib.platforms.all;
  };
})
