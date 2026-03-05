{
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  lib,
}:

buildDotnetModule rec {
  pname = "rofs-extract";
  version = "0-unstable-2026-02-28";

  src = fetchFromGitHub {
    owner = "M-1-RLG";
    repo = "rofs_extract";
    rev = "d6a37a7dff501c1bb0af3d70fb0b4aad5e767d2c";
    hash = "sha256-wSczL9g2Coyvk0hyN2uex96xToCqz62XskerbZb7Ctg=";
  };

  postPatch = ''
    substituteInPlace ${projectFile} \
      --replace-fail "<PublishAot>true" "<PublishAot>false"
  '';

  projectFile = "rofs_extract/rofs_extract.csproj";

  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  meta = with lib; {
    description = "A simple program to extract files from early 3DS ROFS container";
    homepage = "https://github.com/M-1-RLG/rofs_extract";
    license = licenses.mit;
    platform = platforms.all;
    mainProgram = "rofs_extract";
  };
}
