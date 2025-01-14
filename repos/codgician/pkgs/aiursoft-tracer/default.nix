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
    rev = "9c761dbd479b1c6125f497414fa285337e303151";
    hash = "sha256-JDEFBsJhQE2/NWNCNRfHj3FgiPlUbmum2bmuqsj4Qig=";
  };

  version = "1.0.0-${builtins.substring 0 7 src.rev}";

  wwwroot = buildNpmPackage {
    pname = "${pname}-wwwroot";
    src = "${src}/src/wwwroot";
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
