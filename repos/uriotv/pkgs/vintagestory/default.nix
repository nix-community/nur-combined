{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  xorg,
  gtk2,
  sqlite,
  openal,
  cairo,
  libGLU,
  SDL2,
  freealut,
  libglvnd,
  pipewire,
  libpulseaudio,
  dotnet-runtime_8,
  # REQUIRED: Version and hash must be provided
  version,
  hash,
}:

assert lib.assertMsg (version != null) ''
  vintagestory: version is required.

  Usage:
    vintagestory.override {
      version = "1.21.0";
      hash = "sha256-...";
    }

  To get the hash for a version:
    nix-prefetch-url https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_<VERSION>.tar.gz
    nix hash convert --hash-algo sha256 --to sri <HASH>
'';

assert lib.assertMsg (hash != null) ''
  vintagestory: hash is required.

  To get the hash for version ${version}:
    nix-prefetch-url https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${version}.tar.gz
    nix hash convert --hash-algo sha256 --to sri <HASH>
'';

let
  runtimeLibs = lib.makeLibraryPath (
    [
      gtk2
      sqlite
      openal
      cairo
      libGLU
      SDL2
      freealut
      libglvnd
      pipewire
      libpulseaudio
    ]
    ++ (with xorg; [
      libX11
      libXi
      libXcursor
    ])
  );

in
stdenv.mkDerivation {
  pname = "vintagestory";
  inherit version;

  src = fetchurl {
    url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${version}.tar.gz";
    inherit hash;
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "vintagestory";
      desktopName = "Vintage Story";
      exec = "vintagestory";
      icon = "vintagestory";
      comment = "Innovate and explore in a sandbox world";
      categories = [ "Game" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/vintagestory $out/bin $out/share/pixmaps $out/share/fonts/truetype
    cp -r * $out/share/vintagestory
    cp $out/share/vintagestory/assets/gameicon.xpm $out/share/pixmaps/vintagestory.xpm
    cp $out/share/vintagestory/assets/game/fonts/*.ttf $out/share/fonts/truetype

    runHook postInstall
  '';

  preFixup = ''
    makeWrapper ${dotnet-runtime_8}/bin/dotnet $out/bin/vintagestory \
      --prefix LD_LIBRARY_PATH : "${runtimeLibs}" \
      --set-default mesa_glthread true \
      --add-flags $out/share/vintagestory/Vintagestory.dll

    makeWrapper ${dotnet-runtime_8}/bin/dotnet $out/bin/vintagestory-server \
      --prefix LD_LIBRARY_PATH : "${runtimeLibs}" \
      --set-default mesa_glthread true \
      --add-flags $out/share/vintagestory/VintagestoryServer.dll

    find "$out/share/vintagestory/assets/" -not -path "*/fonts/*" -regex ".*/.*[A-Z].*" | while read -r file; do
      local filename="$(basename -- "$file")"
      ln -sf "$filename" "''${file%/*}"/"''${filename,,}"
    done
  '';

  meta = {
    description = "In-development indie sandbox game about innovation and exploration";
    longDescription = ''
      Vintage Story is a sandbox survival game set in a harsh medieval world.

      This package requires explicit version and hash:
        vintagestory.override {
          version = "1.21.0";
          hash = "sha256-90YQOur7UhXxDBkGLSMnXQK7iQ6+Z8Mqx9PEG6FEXBs=";
        }

      Check https://www.vintagestory.at/download/ for available versions.
    '';
    homepage = "https://www.vintagestory.at/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      artturin
      gigglesquid
      niraethm
      dtomvan
    ];
    mainProgram = "vintagestory";
  };
}
