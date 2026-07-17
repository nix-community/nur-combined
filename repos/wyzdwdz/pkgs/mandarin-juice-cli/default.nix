{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
}:
let
  tag = "1.4.1";
in
buildDotnetModule rec {
  pname = "mandarin-juice-cli";
  version = tag;

  src = fetchFromGitHub {
    owner = "mi5hmash";
    repo = "MandarinJuice";
    rev = "v${tag}";
    hash = "sha256-xks2CNmSy6Nw3zP1uGnPLVtdIGQGxyIY2PE/SR3R07M=";
  };

  patches = [
    ./mandarin-juice-cli-xdg-paths.patch
  ];

  projectFile = "mandarin-juice-cli/mandarin-juice-cli.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  executables = [ "mandarin-juice-cli" ];

  meta = with lib; {
    description = "Decrypt, Encrypt & Re-sign files encrypted with the \"Mandarin\" encryption";
    homepage = "https://github.com/mi5hmash/MandarinJuice";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
    ];
    mainProgram = "mandarin-juice-cli";
    broken = false;
  };
}
