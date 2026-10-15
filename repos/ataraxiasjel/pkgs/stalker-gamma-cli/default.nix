{
  lib,
  stdenv,
  buildDotnetModule,
  fetchFromGitHub,
  autoPatchelfHook,
  dotnetCorePackages,
  _7zz-rar,
  cacert,
  curl-impersonate,
  gnutar,
  icu,
  openssl,
  unzip,
  zlib,
  makeDesktopItem,
  copyDesktopItems,
  nix-update-script,
}:
let
  version = "1.37.1";

  src = fetchFromGitHub {
    owner = "FaithBeam";
    repo = "stalker-gamma-cli";
    rev = version;
    sha256 = "sha256-5io4RE3yVNqGcq/oQXcG/8AQilxUqYapaDaKyKnlTj8=";
  };
in
{
  cli = buildDotnetModule {
    pname = "stalker-gamma-cli";
    inherit version src;

    projectFile = "stalker-gamma-cli/stalker-gamma-cli.csproj";
    nugetDeps = ./deps.json;

    dotnet-sdk = dotnetCorePackages.sdk_10_0;
    dotnet-runtime = dotnetCorePackages.runtime_10_0;

    dotnetInstallFlags = [ "-p:AssemblyVersion=1.0.0" ];
    executables = [ "stalker-gamma" ];

    runtimeDeps = [ curl-impersonate ];

    nativeBuildInputs = [ copyDesktopItems ];

    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath [
        _7zz-rar
        gnutar
        unzip
      ])
      # LibCurlImpersonate.dll has the cacert path baked in as a UTF-16 string
      # literal, which the Nix reference scanner cannot see; referencing it from
      # the wrapper keeps it in the runtime closure. Also gives the .NET runtime
      # a working system CA bundle.
      "--set-default"
      "SSL_CERT_FILE"
      "${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];

    postPatch = ''
      # Upstream sets PublishAot=true globally in Directory.Build.props; the
      # CLI is not AOT-compatible, so drop it.
      sed -i -e '/<PublishAot>true<\/PublishAot>/d' Directory.Build.props
      substituteInPlace LibCurlImpersonate/CurlHttp.cs \
        --replace-fail 'private static readonly string PathToCacert = Path.Join(CurDir, "cacert.pem");' \
        'private static readonly string PathToCacert = "${cacert}/etc/ssl/certs/ca-bundle.crt";'
      # NOTE: sed ranges, not multi-line substituteInPlace, on purpose: Nix strips
      # the common indent of indented string blocks, so a multi-line literal
      # pattern silently stops matching upstream. Ranges match
      # content only and survive re-indentation.
      # Anomaly.cs: drop the resources-based 7zz override (no resources/ dir in the nix build).
      sed -i -e '/var resourcesPath = Path\.Join(Path\.GetDirectoryName(AppContext\.BaseDirectory), "resources");/,/);/c\            stalkerGammaSettings.PathTo7Z = "7zz";' stalker-gamma-cli/Commands/Anomaly.cs
      # SetupUtilitiesService.cs: collapse the resources-based assignment to the bare command name.
      sed -i -e '/settings\.PathTo7Z = Path\.Join(/,/);/c\            settings.PathTo7Z = "7zz";' stalker-gamma-cli/Services/SetupUtilitiesService.cs
    '';

    postInstall = ''
      mkdir -p $out/share/icons/hicolor/256x256/apps
      cp $src/build/linux/stalker-gamma.AppDir/stalker-gamma.png $out/share/icons/hicolor/256x256/apps/stalker-gamma.png
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "stalker-gamma";
        desktopName = "Stalker GAMMA";
        genericName = "Stalker GAMMA";
        exec = "stalker-gamma";
        icon = "stalker-gamma";
        categories = [ "Utility" ];
        type = "Application";
        terminal = true;
      })
    ];

    passthru.updateScript = nix-update-script {
      extraArgs = [
        "--flake"
        "stalker-gamma-cli"
      ];
    };

    meta = {
      description = "A CLI to install Stalker GAMMA";
      homepage = "https://github.com/FaithBeam/stalker-gamma-cli";
      license = lib.licenses.gpl3Plus;
      maintainers = [ lib.maintainers.ataraxiasjel ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      mainProgram = "stalker-gamma";
    };
  };

  server = buildDotnetModule {
    pname = "stalker-gamma-server";
    inherit version src;

    projectFile = "stalker-gamma-cli-server/stalker-gamma-cli-server.csproj";
    nugetDeps = ./server-deps.json;

    dotnet-sdk = dotnetCorePackages.sdk_10_0;
    dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;

    # Upstream publishes a self-contained single-file binary; build a
    # framework-dependent one instead so the dotnet
    # runtime comes from the wrapper's closure.
    postPatch = ''
      substituteInPlace stalker-gamma-cli-server/stalker-gamma-cli-server.csproj \
        --replace-fail '<PublishSingleFile>true</PublishSingleFile>' '<PublishSingleFile>false</PublishSingleFile>' \
        --replace-fail '<SelfContained>true</SelfContained>' '<SelfContained>false</SelfContained>'
    '';

    executables = [ "stalker-gamma-server" ];

    # The Microsoft.Playwright nuget ships a prebuilt node binary
    # (.playwright/node/<rid>/node) that the driver spawns at runtime;
    # autoPatchelfHook points it at the nix store.
    nativeBuildInputs = [ autoPatchelfHook ];

    buildInputs = [
      stdenv.cc.cc.lib
      icu
      openssl
      zlib
    ];

    passthru.updateScript = nix-update-script {
      extraArgs = [
        "--flake"
        "stalker-gamma-server"
      ];
    };

    meta = {
      description = "Local server solving ModDB Cloudflare challenges for stalker-gamma-cli via a Camoufox browser container";
      longDescription = ''
        Companion server for stalker-gamma-cli (--stalker-gamma-server-url).
        Requires a running Docker daemon: on first start it pulls the
        faithbeam/stalker-gamma-camoufox-server image (~850 MB) and runs the
        Camoufox browser in a container. Listens on http://localhost:5000
        (/livez, /readyz, /navigate).
      '';
      homepage = "https://github.com/FaithBeam/stalker-gamma-cli";
      license = lib.licenses.gpl3Plus;
      maintainers = [ lib.maintainers.ataraxiasjel ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      mainProgram = "stalker-gamma-server";
    };
  };
}
