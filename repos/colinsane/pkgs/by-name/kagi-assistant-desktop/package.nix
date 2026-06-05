# package based on:
# - <https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=kagi-assistant-desktop-git>
#
# thoughts:
# - the UI is too broken to be navigable
# - perhaps it needs more assets (e.g. style/css files) to be linked into the output?
{
  bun,
  fetchFromGitHub,
  lib,
  rustPlatform,
  typescript,
  webkitgtk_4_1,
  writableTmpDirAsHomeHook,
  stdenvNoCC,
  nodejs,
  pkg-config,
  glib-networking,
  openssl,
}:
let
  pname = "kagi-assistant-desktop";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "0xgingi";
    repo = "kagi-assistant-desktop";
    tag = "v${version}";
    hash = "sha256-8uvp8J/+x4XmkY7Oi2N7v/VkyoXDW2MnRG/yuUjJDKE=";
  };
  node_modules = stdenvNoCC.mkDerivation {
    pname = "${pname}-node_modules";
    inherit version src;

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      bun install \
        --cpu="*" \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --os="*"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      find . -type d -name node_modules -exec cp -R --parents {} $out \;

      runHook postInstall
    '';

    dontFixup = true;

    outputHash = "sha256-XXBze+4kf6h1qjKLek8gWUqpYVEFVr90N3OiBiyJwa0=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

in
rustPlatform.buildRustPackage (finalAttrs: {
  inherit pname src version;

  cargoHash = "sha256-iMTd+hIuhcjiZWyWrVJDSNBIP+JgbCyS3I7YjQ1emDw=";

  # sourceRoot = "src/src-tauri";
  cargoRoot = "src-tauri";

  postPatch = ''
    cp -R ${node_modules}/. .
    patchShebangs --build ./node_modules
  '';

  buildPhase = ''
    runHook preBuild
    bun run tauri build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 src-tauri/target/release/kagi-assistant-desktop $out/bin/kagi-assistant-desktop
    install -Dm644 src-tauri/icons/kagi.png \
      $out/share/icons/hicolor/512x512/apps/kagi-assistant-desktop.png
    install -Dm644 public/kagi.svg \
      $out/share/icons/hicolor/scalable/apps/kagi-assistant-desktop.svg
    runHook postInstall
  '';

  doCheck = false;

  nativeBuildInputs = [
    bun
    nodejs
    pkg-config
    typescript
  ];
  buildInputs = [
    glib-networking  # else "TLS is not available"
    openssl
    webkitgtk_4_1
  ];

  passthru = {
    inherit node_modules;
  };

  meta = {
    description = "A desktop application for Kagi Assistant built with Tauri.";
    homepage = "https://github.com/0xgingi/kagi-assistant-desktop";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
