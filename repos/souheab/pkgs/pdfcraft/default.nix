{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchurl,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  vulkan-loader,
  wayland,
}:

let
  # Pinned by .github/workflows/release.yml; embedded for Japanese and Arabic text.
  craftFonts = fetchFromGitHub {
    owner = "storytold";
    repo = "craft-fonts";
    rev = "3d9ab3a132ed0eff457e424226a435a901da30d3";
    hash = "sha256-mNnDzBcOp1X10dzmiW0iBAkb74QjuzMO4slWudxXCTE=";
  };

  # OCR models listed in ATTRIBUTION.toml, normally fetched by `cargo xtask models`.
  ocrModels = {
    "text-detection.rten" = fetchurl {
      url = "https://ocrs-models.s3-accelerate.amazonaws.com/text-detection.rten";
      sha256 = "f15cfb56bd02c4bf478a20343986504a1f01e1665c2b3a0ad66340f054b1b5ca";
    };
    "text-recognition.rten" = fetchurl {
      url = "https://ocrs-models.s3-accelerate.amazonaws.com/text-recognition.rten";
      sha256 = "e484866d4cce403175bd8d00b128feb08ab42e208de30e42cd9889d8f1735a6e";
    };
  };

  # Windowing and GPU libraries are loaded with dlopen at runtime.
  runtimeLibs = [
    libGL
    libx11
    libxcursor
    libxi
    libxkbcommon
    libxrandr
    vulkan-loader
    wayland
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pdfcraft";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "pdfcraft";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UCTQr6j4TqPXQWH410cF6DZC0vK59QFv1FAWzxdDjwA=";
  };

  cargoHash = "sha256-L0fC96fLlwTq0Gu0CSL9swKzZe4lcgLFsMsaIk3CxuY=";

  # nixpkgs' rustc links LLVM 21, which rejects stdarch's `_mm512_dpbusd_epi32`.
  # Emit the instruction with inline asm, as rten-gemm's x86_64 kernel already does.
  postPatch = ''
    i8dot="$(find "$cargoDepsCopy" -type f -path '*/rten-gemm-*/src/i8dot.rs' -print -quit)"

    if [[ -z "$i8dot" ]]; then
      echo "could not locate rten-gemm in $cargoDepsCopy" >&2
      exit 1
    fi

    substituteInPlace "$i8dot" \
      --replace-fail \
        "use std::arch::x86_64::_mm512_dpbusd_epi32;" \
        "" \
      --replace-fail \
        "_mm512_dpbusd_epi32(acc.0, a.0, b.0).into()" \
        "{ let mut c = acc.0; std::arch::asm!(\"vpdpbusd {c}, {a}, {b}\", c = inout(zmm_reg) c, a = in(zmm_reg) a.0, b = in(zmm_reg) b.0, options(pure, nomem, nostack)); c.into() }"
  '';

  cargoBuildFlags = [
    "-p"
    "pdfcraft"
    "-p"
    "pdfcraft-cli"
  ];

  env = {
    CRAFT_FONTS_DIR = craftFonts;
    CRAFT_FONTS_REQUIRED = "1";
  };

  doCheck = false;

  postInstall = ''
    appId=ai.storyteller.pdfcraft
    install -Dm644 packaging/linux/$appId.desktop -t $out/share/applications
    install -Dm644 packaging/linux/$appId.mime.xml $out/share/mime/packages/$appId.xml
    mkdir -p $out/share/icons
    cp -R assets/app-icon/hicolor $out/share/icons/

    mkdir -p $out/share/pdfcraft/models
    ${lib.concatStrings (
      lib.mapAttrsToList (name: model: ''
        ln -s ${model} $out/share/pdfcraft/models/${name}
      '') ocrModels
    )}
  '';

  postFixup = ''
    patchelf --add-rpath ${lib.makeLibraryPath runtimeLibs} $out/bin/pdfcraft
  '';

  passthru = { inherit craftFonts ocrModels; };

  meta = {
    description = "Open-source PDF reader and editor written in pure Rust";
    homepage = "https://getartcraft.com/apps/pdfcraft";
    changelog = "https://github.com/storytold/pdfcraft/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "pdfcraft";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode # Pretrained OCR models
    ];
    maintainers = [
      {
        name = "Souheab";
        github = "Souheab";
        githubId = 85948717;
      }
    ];
    platforms = lib.platforms.linux;
  };
})
