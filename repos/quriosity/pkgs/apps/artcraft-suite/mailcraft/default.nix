{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  autoPatchelfHook,
  makeWrapper,
  pkg-config,
  libxcb,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  wayland,
  libxkbcommon,
  libGL,
  vulkan-loader,
  nix-update-script,
}:

let
  runtimeLibs = [
    stdenv.cc.cc.lib
    wayland
    libxkbcommon
    libxcb
    libx11
    libxcursor
    libxi
    libxrandr
    libGL
    vulkan-loader
  ];
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mailcraft";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "UCS-Care-Group";
    repo = "mailcraft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-s3cgsm34LkM0xvp8VFzSQl0zSNR6g5sxE3jAjKzmOT4=";
  };

  cargoHash = "sha256-F527QsuNIx0NQrww98QHFCpxdih2DO1XmrhZ8Wd7kzw=";
  cargoBuildFlags = [ "--package" "mailcraft" "--package" "mailcraft-cli" ];
  cargoTestFlags = [ "--package" "mailcraft" "--package" "mailcraft-cli" ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = runtimeLibs;
  runtimeDependencies = runtimeLibs;

  postInstall = ''
    mkdir -p $out/share/applications $out/share/icons $out/share/metainfo
    install -Dm644 packaging/linux/io.github.billsecond.mailcraft.desktop \
      $out/share/applications/io.github.billsecond.mailcraft.desktop
    cp -r assets/app-icon/hicolor $out/share/icons/
    sed -e "s|@VERSION@|${finalAttrs.version}|" \
      -e "s|@DATE@|$(date -u -d @$SOURCE_DATE_EPOCH +%F 2>/dev/null || true)|" \
      packaging/linux/io.github.billsecond.mailcraft.metainfo.xml.in \
      > $out/share/metainfo/io.github.billsecond.mailcraft.metainfo.xml

    wrapProgram $out/bin/mailcraft \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "An open-source mail, calendar, contacts and tasks program written in Rust";
    homepage = "https://mailcraft.work/";
    license = [ licenses.mit licenses.asl20 ];
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "mailcraft";
  };
})
