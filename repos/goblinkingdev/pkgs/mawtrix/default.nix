{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnet-sdk_8,
  dotnet-runtime_8,
  openssl,
}:

buildDotnetModule rec {
  pname = "mawtrix";
  version = "0.8";

  src = fetchFromGitHub {
    owner = "Entarno54";
    repo = "Mawtrix";
    rev = "v8";
    hash = "sha256-xDn1/VORrYtsDUKCHnRHn7j6dtRqxexjBZKamnzuotw=";
  };

  nugetDeps = ./deps.json;

  projectFile = "Mawtrix/Mawtrix.csproj";
  executables = [ "Mawtrix" ];

  dotnet-sdk = dotnet-sdk_8;
  dotnet-runtime = dotnet-runtime_8;

  buildInputs = [ openssl ];

  meta = with lib; {
    description = "A simple Matrix TUI client written in C#";
    homepage = "https://github.com/Entarno54/Mawtrix";
    changelog = "https://github.com/Entarno54/Mawtrix/commits/main";
    license = licenses.mit;
    maintainers = with maintainers; [ "goblinkingdev" ];
    mainProgram = "Mawtrix";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
