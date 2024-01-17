{ sources, rustPlatform, lib, pkg-config, rlottie, ffmpeg_5, clang }:

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
    # TODO wait for a release supporting ffmpeg 6.1
    # https://github.com/LuckyTurtleDev/mstickereditor/releases
    # https://github.com/LuckyTurtleDev/mstickereditor/pull/42
    ffmpeg_5
  ];

  meta = with lib; {
    homepage = "https://github.com/LuckyTurtleDev/mstickereditor";
    description = "Import sticker packs from telegram, to be used at the Maunium sticker picker for Matrix";
    license = licenses.asl20;
    maintainers = with maintainers; [ yinfeng ];
  };
}
