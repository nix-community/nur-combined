{
  lib,
  stdenv,
  buildDotnetModule,
  fetchFromGitHub,
  nix-update-script,
  dotnetCorePackages,
  copyDesktopItems,
  makeDesktopItem,
  autoPatchelfHook,
  clang,
  lld,
  icoutils,
  fontconfig,
  glew,
  libGL,
  libice,
  libsm,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxrandr,
  zlib,
}:

buildDotnetModule (finalAttrs: {
  pname = "nattypetester";
  version = "10.0.8";

  src = fetchFromGitHub {
    owner = "HMBSbige";
    repo = "NatTypeTester";
    tag = finalAttrs.version;
    hash = "sha256-Q/70qkbmyjxf302OzQaZJj4q5LzpwE2uX790O5qK5k0=";
  };

  projectFile = "src/NatTypeTester.Desktop/NatTypeTester.Desktop.csproj";

  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  dotnetFlags = [
    "-p:MinVerVersionOverride=${finalAttrs.version}"
  ];

  selfContainedBuild = true;

  executables = [ "NatTypeTester" ];

  nativeBuildInputs = [
    autoPatchelfHook
    clang
    lld
    copyDesktopItems
    icoutils
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    fontconfig
    zlib
  ];

  runtimeDeps = [
    fontconfig
    glew
    libGL
    libice
    libsm
    libx11
    libxcursor
    libxext
    libxi
    libxrandr
    zlib
  ];

  # NuGet's signing certificate for the pinned ReactiveUI/Splat packages was
  # revoked. Nix still verifies every downloaded nupkg against deps.json.
  env.DOTNET_NUGET_SIGNATURE_VERIFICATION = "false";

  postInstall = ''
    for entry in 16:5 24:10 32:15 48:20 64:25 256:30; do
      size=''${entry%%:*}
      index=''${entry##*:}
      iconDir="$out/share/icons/hicolor/''${size}x''${size}/apps"
      mkdir -p "$iconDir"
      icotool --icon --extract --index "$index" \
        --output "$iconDir/nattypetester.png" \
        src/NatTypeTester.Views/Assets/icon.ico
    done
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "nattypetester";
      desktopName = "NatTypeTester";
      genericName = "NAT type tester";
      comment = finalAttrs.meta.description;
      exec = "NatTypeTester";
      icon = "nattypetester";
      categories = [ "Network" ];
      terminal = false;
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "测试当前网络的 NAT 类型（STUN）";
    homepage = "https://github.com/HMBSbige/NatTypeTester";
    changelog = "https://github.com/HMBSbige/NatTypeTester/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hhr2020 ];
    mainProgram = "NatTypeTester";
    platforms = lib.platforms.linux;
  };
})
