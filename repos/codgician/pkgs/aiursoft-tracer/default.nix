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
    rev = "88d82b991b9598cf06a3c42b6bb11c581a8a1697";
    hash = "sha256-EnMMj2wRsqX0i8tMgNiqHBhtJLYliVtb1VJ9PQshClc=";
  };

  version = "0-unstable-2026-06-24";

  wwwroot = buildNpmPackage {
    pname = "${pname}-wwwroot";
    src = "${src}/src/Aiursoft.Tracer/wwwroot";
    inherit version;
    npmDepsHash = "sha256-Gf53euGKcC0LQ6I1pCo+t6tXnuqv9bfFPYhz0lcNBSM=";
    dontNpmBuild = true;

    # The upstream lockfile pins some packages to Aiursoft's private npm
    # registry, which is unreliable (Cloudflare 525 errors). Fetch them from
    # the official registry instead; the tarballs are byte-identical.
    postPatch = ''
      substituteInPlace package-lock.json \
        --replace-fail "https://npm.aiursoft.com/" "https://registry.npmjs.org/"
    '';

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
