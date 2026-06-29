{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  copyDesktopItems,
  makeDesktopItem,
  imagemagick,
  libx11,
  libSM,
  fontconfig,
  libICE,
  libGL,
}:

buildDotnetModule rec {
  pname = "banguminet";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "ajtn123";
    repo = "BangumiNet";
    rev = "v${version}";
    hash = "sha256-xJS99VVaYFUr2wYqG9lYwDpvUiNqb/xy7CJGW2iLAcM=";
  };

  projectFile = "BangumiNet/BangumiNet.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  executables = [ "BangumiNet" ];

  runtimeDeps = [
    libx11
    libSM
    libICE
    fontconfig.lib
    libGL
  ];

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "banguminet";
      desktopName = "BangumiNet";
      exec = "banguminet";
      icon = "banguminet";
      comment = "Third-party Bangumi desktop client";
      terminal = false;
      type = "Application";
      categories = [ "Network" ];
    })
  ];

  postInstall = ''
    mkdir -p "$out/bin"
    ln -s "$out/bin/BangumiNet" "$out/bin/banguminet"

    # Convert multi-frame .ico → .png, picking the largest frame by pixel area
    tmpdir=$(mktemp -d)
    magick "$src/BangumiNet/Assets/BangumiNet.ico" "$tmpdir/frame.png"
    largest=$(
      magick identify -format "%w %h %f\n" "$tmpdir"/frame-*.png \
        | sort -t' ' -k1,1nr -k2,2nr | head -1 | awk '{print $3}'
    )
    install -Dm644 "$tmpdir/$largest" "$out/share/pixmaps/banguminet.png"
    rm -r "$tmpdir"
  '';

  meta = with lib; {
    description = "Third-party Bangumi desktop client built with .NET and Avalonia";
    homepage = "https://github.com/ajtn123/BangumiNet";
    license = licenses.mit;
    mainProgram = "banguminet";
    platforms = dotnetCorePackages.sdk_10_0.meta.platforms or platforms.linux;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
