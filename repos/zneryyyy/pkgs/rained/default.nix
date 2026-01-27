{
  lib,
  makeBinaryWrapper,
  buildDotnetModule,
  dotnetCorePackages,
  fetchgit,
  python313,
  wayland,
  libxkbcommon,
  libglvnd,
  freetype,
  imgui,
}:

buildDotnetModule rec {
  name = "rained";
  version = "2.4.0";

  src = fetchgit {
    url = "https://github.com/pkhead/rained.git";
    tag = "v${version}";
    sha256 = "AQRZAgq95B3CIFo1V5KPlGcmbxW/J4tpYJGzW466Lh4=";
    fetchSubmodules = true;
  };

  projectFile = [
    "src/Rained/Rained.csproj"
    "src/Drizzle/Drizzle.Transpiler/Drizzle.Transpiler.csproj"
  ];
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  buildInputs = [
    python313
  ];

  nativeBulidInputs = [
    makeBinaryWrapper
  ];

  runtimeDeps = [
    wayland
    libxkbcommon
    libglvnd
    freetype
    imgui
  ];

  executables = [ "Rained" ];

  dotnetBuildFlags = [ "/p:AppDataPath=AppData" ];

  preBuild = ''
    cd src/Drizzle
    dotnet run --project Drizzle.Transpiler --no-restore
    cd ../..
    dotnet run --project src/DrizzleExport.Console effects src/Rained/Assets/effects.json

    python3 lua-imgui-gen.py
  '';

  postFixup = ''
    mkdir -p $out/share/logs
    cp -r assets/ $out/share/assets
    cp -r config/ $out/share/config
    cp -r docs/ $out/share/docs
    cp -r scripts/ $out/share/scripts

    wrapProgram $out/bin/Rained \
      --run '
        CONFIG="''${XDG_CONFIG_HOME:-$HOME/.config}/rained"
        INSTALLED="$CONFIG/.installed"

        if [[ ! -f "$INSTALLED" ]]; then
          mkdir -p "$CONFIG"
          cp -r --update=none '"$out"'/share/* "$CONFIG/"
          touch "$INSTALLED"
          chmod -R u+w $CONFIG
        fi
      '
  '';

  meta = with lib; {
    description = "Rain World level editor";
    homepage = "https://github.com/pkhead/rained";
    changelog = "https://github.com/pkhead/rained/releases/tag/${src.tag}";
    mainProgram = "Rained";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
