{
  fetchFromGitHub,
  lib,
  callPackage,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
}:
let
  cleanuparrFlmQbittorrentSrc = fetchFromGitHub {
    owner = "Cleanuparr";
    repo = "qbittorrent-net-client";
    rev = "b36a3ca40c83776f9f1b86a56e46ae718e2cf96f";
    hash = "sha256-33M+j8Phukwa5R7zo5Nuc/rSb2Dv2JYfTcXZMkFu7jw=";
  };
  cleanuparrFlmTransmissionSrc = fetchFromGitHub {
    owner = "Cleanuparr";
    repo = "Transmission.API.RPC";
    rev = "1d2548c3c888a2d8b0a2bf4fbefe2f91e981e263";
    hash = "sha256-JFmTyRzHN3fDdZOoeFz89fk7kroT33tceoUpVBoWS5g=";
  };

  frontend = callPackage ./frontend.nix { };
  flmQbittorrentSrc = cleanuparrFlmQbittorrentSrc;
  flmTransmissionSrc = cleanuparrFlmTransmissionSrc;
in
buildDotnetModule (finalAttrs: {
  pname = "cleanuparr";
  version = "2.10.5";
  src = fetchFromGitHub {
    owner = "Cleanuparr";
    repo = "Cleanuparr";
    tag = "v2.10.5";
    hash = "sha256-jaBAT3DWbsE5upQD4rERUVW/sb5Hu8pyuY7RdvhVDMs=";
  };
  __structuredAttrs = true;

  sourceRoot = "source/code/backend";
  projectFile = "Cleanuparr.Api/Cleanuparr.Api.csproj";

  nugetDeps = ./nuget-deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  selfContainedBuild = true;
  dotnetFlags = [
    "-p:PublishSingleFile=true"
    "-p:DebugSymbols=false"
  ];

  executables = [ "Cleanuparr" ];

  postPatch = ''
    # Drop in the private FLM.* libraries (only published to GitHub Packages)
    # as regular project references so the build never needs authenticated NuGet.
    mkdir -p _flm/QBittorrent _flm/Transmission
    cp -r ${flmQbittorrentSrc}/src/QBittorrent.Client/. _flm/QBittorrent/
    cp -r ${flmTransmissionSrc}/Transmission.API.RPC/. _flm/Transmission/

    substituteInPlace Cleanuparr.Infrastructure/Cleanuparr.Infrastructure.csproj \
      --replace-fail '<PackageReference Include="FLM.QBittorrent" Version="1.0.3" />' '<ProjectReference Include="../_flm/QBittorrent/QBittorrent.Client.csproj" />' \
      --replace-fail '<PackageReference Include="FLM.Transmission" Version="1.0.3" />' '<ProjectReference Include="../_flm/Transmission/Transmission.API.RPC.csproj" />'

    # The forked csproj packs a nupkg on build; we only need the assembly.
    substituteInPlace _flm/QBittorrent/QBittorrent.Client.csproj \
      --replace-fail '<GeneratePackageOnBuild>true</GeneratePackageOnBuild>' '<GeneratePackageOnBuild>false</GeneratePackageOnBuild>'

    # Serve the prebuilt Angular frontend as static web assets.
    rm -rf Cleanuparr.Api/wwwroot
    cp -r ${frontend}/wwwroot Cleanuparr.Api/wwwroot
  '';

  postFixup = ''
    ln -s Cleanuparr $out/bin/cleanuparr
  '';

  # Write runtime config/logs outside the read-only store by default.
  makeWrapperArgs = [
    "--chdir"
    "${placeholder "out"}/lib/cleanuparr"
    "--run"
    ''export CLEANUPARR_CONFIG_PATH="''${CLEANUPARR_CONFIG_PATH:-''${XDG_CONFIG_HOME:-$HOME/.config}/cleanuparr}"''
  ];

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Advanced download manager for the Servarr ecosystem";
    homepage = "https://github.com/Cleanuparr/Cleanuparr";
    license = lib.licenses.gpl3Only;
    mainProgram = "cleanuparr";
    platforms = [ "x86_64-linux" ];
  };
})
