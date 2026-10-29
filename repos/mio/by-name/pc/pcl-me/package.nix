{
  lib,
  stdenv,
  fetchFromGitHub,
  dotnetCorePackages,
  fontconfig,
  cacert,
  makeWrapper,
  writeShellApplication,
  nix-update-script,
}:

let
  pname = "pcl-me";
  version = "1.0.0-beta.7-unstable-2026-10-28";

  src = fetchFromGitHub {
    owner = "TheUnknownThing";
    repo = "PCL-ME";
    rev = "0a040635d6aece366c689b6a9877da1886ffa0b2";
    hash = "sha256-mNRWbOZhY6zhot5Kaw3csBwK4J1qjz24y3IRLNHCxHM=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  deps = stdenv.mkDerivation {
    name = "${pname}-deps-${version}";
    inherit src;

    nativeBuildInputs = [
      dotnet-sdk
      cacert
    ];

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-0oTvKobby4skC/SaAqju9Yi/dhj9S7rw+yV4Fa8yz4c=";

    buildPhase = ''
      export DOTNET_NOLOGO=1
      export DOTNET_CLI_TELEMETRY_OPTOUT=1
      export HOME=$TMPDIR

      dotnet restore "Plain Craft Launcher 2.slnx" --packages $out --source https://api.nuget.org/v3/index.json
    '';

    installPhase = "true";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    dotnet-sdk
    makeWrapper
  ];
  buildInputs = [ fontconfig ];

  # Avalonia's build task phones home and creates a telemetry directory under
  # the home directory, which is not writable in the sandbox (on Darwin it
  # resolves to /var/empty). The sandbox has no network anyway.
  env.AVALONIA_TELEMETRY_OPTOUT = "1";

  buildPhase = ''
    export DOTNET_NOLOGO=1
    export DOTNET_CLI_TELEMETRY_OPTOUT=1
    export HOME=$TMPDIR
    export NUGET_PACKAGES=${deps}

    # We must restore again using offline cache to generate obj/ files
    dotnet restore "Plain Craft Launcher 2.slnx" --source ${deps}

    dotnet publish "PCL.Frontend.Avalonia/PCL.Frontend.Avalonia.csproj" \
      --no-restore \
      -c Release \
      -o $out/bin \
      -p:UseAppHost=true \
      -p:ContinuousIntegrationBuild=true
  '';

  installPhase = ''
    wrapProgram $out/bin/PCL.Frontend.Avalonia \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ fontconfig ]}"
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-pcl-me";
    text = ''
      export UPDATE_NIX_ATTR_PATH="pcl-me"
      exec ${
        lib.escapeShellArgs (nix-update-script {
          extraArgs = [ "--version=branch" ];
        })
      } "$@"
    '';
  };

  meta = with lib; {
    description = "A cross-platform Plain Craft Launcher";
    homepage = "https://github.com/TheUnknownThing/PCL-ME";
    license = licenses.mit;
    mainProgram = "PCL.Frontend.Avalonia";
  };
}
