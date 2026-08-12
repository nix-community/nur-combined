{
  sources,
  rustPlatform,
  lib,
  pkg-config,
  rlottie,
  ffmpeg_6,
  clang,
}:

rustPlatform.buildRustPackage {
  inherit (sources.mstickereditor) pname version src;
  cargoLock = sources.mstickereditor.cargoLock."Cargo.lock";

  postPatch = ''
    rm -r .cargo
  '';

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    pkg-config
    clang
  ];
  buildInputs = [
    rlottie
    ffmpeg_6
  ];

  meta = with lib; {
    homepage = "https://github.com/LuckyTurtleDev/mstickereditor";
    description = "Import sticker packs from telegram, to be used at the Maunium sticker picker for Matrix";
    license = licenses.asl20;
    broken = !(versionAtLeast (versions.majorMinor trivial.version) "24.05");
    maintainers = with maintainers; [ yinfeng ];
  };
}
