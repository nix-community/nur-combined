{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnet-sdk_8,
  dotnet-runtime_8,
  openssl,
  libx11,
  libxkbcommon,
  fontconfig,
}:

buildDotnetModule rec {
  pname = "pawtrix";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "Entarno54";
    repo = "Pawtrix";
    rev = "26871e2195bb58e5c0ea133668a7330ce1da5843";
    hash = "sha256-xbJVLbrk9R8AN5+4tV/bmZfH1xsvdGSR0l9fKJqRF00=";
  };

  nugetDeps = ./deps.json;

  projectFile = "Pawtrix/Pawtrix.csproj";
  executables = [ "Pawtrix" ];

  dotnet-sdk = dotnet-sdk_8;
  dotnet-runtime = dotnet-runtime_8;

  buildInputs = [
    openssl
    libx11
    libxkbcommon
    fontconfig
  ];

  meta = with lib; {
    description = "A Matrix client in C# using the Avalonia framework";
    homepage = "https://github.com/Entarno54/Pawtrix";
    changelog = "https://github.com/Entarno54/Pawtrix/commits/main";
    license = licenses.mit;
    maintainers = with maintainers; [ "goblinkingdev" ];
    mainProgram = "Pawtrix";
    platforms = platforms.linux;
  };
}
