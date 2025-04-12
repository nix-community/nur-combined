{
  lib,
  pkgs,
  buildDotnetModule,
  dotnetCorePackages,
  buildNpmPackage,
  fetchFromGitHub,
  ...
}:

let
  pname = "aiursoft-tracer";
  src = fetchFromGitHub {
    owner = "AiursoftWeb";
    repo = "Tracer";
    rev = "712292032e9dcdb2ccb35d9b3df0e428d19c0b0d";
    hash = "sha256-hi2BemCMtX9A+89o0J/C70Zvikzh0JpKteS+9Xhy1Co=";
  };

  version = "0-unstable-2025-04-11";

  wwwroot = buildNpmPackage {
    pname = "${pname}-wwwroot";
    src = "${src}/src/Aiursoft.Tracer/wwwroot";
    inherit version;
    npmDepsHash = "sha256-6gfwlUqi0coQ4qoQyw3M1cPWTCjtbWyhl7wtVdhvGKc=";
    dontNpmBuild = true;

    installPhase = ''
      mkdir -p $out
      cp -r * $out
    '';
  };
in
buildDotnetModule {
  inherit
    pname
    src
    version
    wwwroot
    ;

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_9_0;
  nugetDeps = ./deps.json;

  nativeBuildInputs = with pkgs; [ patchelf ];

  projectFile = "Aiursoft.Tracer.sln";

  postFixup = ''
    # Symlink wwwroot
    rm -rf $out/lib/${pname}/wwwroot
    mkdir -p $out/assets
    ln -s ${wwwroot} $out/assets/wwwroot

    # Patch working directory
    dir=$out/assets
    sedexpr='s/\(exec.*Aiursoft\.Tracer.*\)/(cd '
    sedexpr+=''${dir//\//\\/}
    sedexpr+=' \&\& \1)/g'
    sed -i -e "$sedexpr" $out/bin/Aiursoft.Tracer
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    homepage = "https://tracer.aiursoft.cn";
    description = "Tracer is a simple network speed test app.";
    license = licenses.mit;
    mainProgram = "Aiursoft.Tracer";
  };
}
