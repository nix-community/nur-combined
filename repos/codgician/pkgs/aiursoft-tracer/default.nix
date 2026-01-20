{
  lib,
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
    rev = "c67b0dd8ee2dd2a770540b7cbed2758be1c390ef";
    hash = "sha256-M+bTGJDOqiamGi0kbXX7y4teb1EJfYGj3/WX71AqdGo=";
  };

  version = "0-unstable-2026-01-20";

  wwwroot = buildNpmPackage {
    pname = "${pname}-wwwroot";
    src = "${src}/src/Aiursoft.Tracer/wwwroot";
    inherit version;
    npmDepsHash = "sha256-wLrgYSVyHpxAAa2wJCxjXtFp3QaaiH4SxdslGZANhDE=";
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

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;
  nugetDeps = ./deps.json;

  projectFile = "Aiursoft.Tracer.sln";
  enableParallelBuilding = false;

  postPatch = ''
    substituteInPlace nuget.config \
      --replace-fail "https://nuget.aiursoft.com/v3/index.json" "https://api.nuget.org/v3/index.json"
  '';

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
