# Revue's release binary: the release's Linux tarball, patched to the Nix
# store's libraries. Its version and checksum are filled in by `task
# release:publish:managers` in Revue's repository at each release.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  addDriverRunpath,
  wayland,
  libxkbcommon,
  libxcb,
  libx11,
  libxcursor,
  libxrandr,
  libxi,
  vulkan-loader,
  libGL,
  fontconfig,
  freetype,
  zstd,
  git,
  gh,
  libsecret,
}:

let
  # The release's tarball for each system it's built for.
  sources = {
    x86_64-linux = {
      arch = "x86_64";
      sha256 = "90c36ca281c56903d6b1022ceacb8ab0b30502ec6e298cdf94905486060b3db5";
    };
    aarch64-linux = {
      arch = "aarch64";
      sha256 = "cf735dce4085a75038ea93239e252ea9f2a7470a0e893b3836fe5f1368a0817d";
    };
  };
  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "revue-bin: no release build for ${stdenv.hostPlatform.system}");
  # GPUI loads these at runtime, so they go on LD_LIBRARY_PATH too.
  runtimeLibs = [
    wayland
    libxkbcommon
    libxcb
    libx11
    libxcursor
    libxrandr
    libxi
    vulkan-loader
    libGL
    fontconfig
    freetype
    zstd
  ];
in
stdenv.mkDerivation rec {
  pname = "revue-bin";
  version = "0.44.6";
  src = fetchurl {
    url = "https://forgejo.cleangame.dev/thatrichan/revue/releases/download/v${version}/revue-v${version}-linux-${source.arch}.tar.gz";
    inherit (source) sha256;
  };
  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = runtimeLibs ++ [ stdenv.cc.cc.lib ];
  installPhase = ''
    runHook preInstall
    install -Dm755 revue $out/bin/revue
    install -Dm644 revue.desktop $out/share/applications/revue.desktop
    for f in icons/revue-*.png; do
      n=''${f#icons/revue-}
      n=''${n%.png}
      install -Dm644 "$f" $out/share/icons/hicolor/''${n}x''${n}/apps/revue.png
    done
    install -Dm644 -t $out/share/licenses/revue LICENSE-MIT LICENSE-APACHE THIRD-PARTY-LICENSES.md
    runHook postInstall
  '';
  # NixOS puts the GPU drivers in /run/opengl-driver. Revue runs git,
  # gh (GitHub sign-in) and secret-tool (tokens in the keyring).
  postFixup = ''
    wrapProgram $out/bin/revue \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}:${addDriverRunpath.driverLink}/lib \
      --prefix PATH : ${
        lib.makeBinPath [
          git
          gh
          libsecret
        ]
      }
  '';
  meta = {
    description = "Fast native code review app";
    homepage = "https://revue.cleangame.dev/";
    license = with lib.licenses; [
      mit
      asl20
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames sources;
    mainProgram = "revue";
  };
}
