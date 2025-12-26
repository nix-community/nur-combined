{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  sources,
  source ? sources.gzctf,
  dotnetCorePackages,
  callPackage,
  icu,

  xmlstarlet,

  libgdiplus,
  zlib,
  libpcap,
  krb5,
  openssl,

  serverPort ? 28080,
  metricPort ? 23000,
}:

buildDotnetModule (finalAttrs: {
  pname = "gzctf";
  inherit (source) version;

  src = fetchFromGitHub {
    owner = "GZTimeWalker";
    repo = "GZCTF";
    inherit (source.src) rev;
    hash = "sha256-XYWqHOsK4LfEt8JQxzsXRhC5abRBz/Pwmpew7j+txv4=";
    leaveDotGit = true;
    postFetch = ''
      git -C $out rev-parse HEAD > $out/.git_head
      date -u -d "@$(git -C $out log -1 --pretty=%ct)" "+%Y-%m-%dT%H:%M:%SZ" > $out/.git_time
      rm -rf $out/.git
    '';
  };

  postPatch = ''
    xmlstarlet ed -L \
      -d "//Target[@Name='PublishFrontend']" \
      ${finalAttrs.projectFile}

    substituteInPlace src/GZCTF/Server.cs \
      --replace-fail 'MetricPort = 3000' 'MetricPort = ${toString metricPort}' \
      --replace-fail 'ServerPort = 8080' 'ServerPort = ${toString serverPort}'
  '';

  projectFile = "src/GZCTF/GZCTF.csproj";
  testProjectFile = [
    "src/GZCTF.Test/GZCTF.Test.csproj"
    "src/GZCTF.Integration.Test/GZCTF.Integration.Test.csproj"
  ];
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;
  nugetDeps = ./deps.json;
  nativeBuildInputs = [ xmlstarlet ];
  runtimeDeps = [
    libgdiplus
    libpcap
    openssl
    icu
    zlib
    krb5
  ];

  dotnetFlags = [
    # this removes the Microsoft.WindowsDesktop.App.Ref dependency
    "-p:EnableWindowsTargeting=false"
    "-p:PublishReadyToRun=false"
  ];
  dotnetBuildFlags = [ "--no-self-contained" ];

  preBuild = ''
    export VITE_APP_BUILD_TIMESTAMP=$(<${finalAttrs.src}/.git_time)
    export VITE_APP_GIT_SHA=$(<${finalAttrs.src}/.git_head)
    export VITE_APP_GIT_NAME=v${lib.head (lib.strings.splitString "-" finalAttrs.version)}
  '';

  executables = [ "GZCTF" ];

  makeWrapperArgs = [
    "--add-flags"
    "--webroot=${finalAttrs.passthru.frontend}"
  ];

  passthru = {
    # nix-update auto -sfrontend
    frontend = callPackage ./frontend.nix {
      inherit (finalAttrs)
        pname
        version
        src
        preBuild
        ;
    };
  };

  meta = {
    description = "Open source CTF platform";
    homepage = "https://github.com/GZTimeWalker/GZCTF";
    license = [
      lib.licenses.agpl3Only
      {
        fullName = "GZCTF Restricted License";
        url = "https://github.com/GZTimeWalker/GZCTF/blob/develop/license/LicenseRef-GZCTF-Restricted.txt";
        free = false;
        redistributable = true;
      }
    ];
    mainProgram = "GZCTF";
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
