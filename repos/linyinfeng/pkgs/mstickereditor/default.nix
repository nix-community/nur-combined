{ sources, rustPlatform, lib, pkg-config, rlottie, clang }:

rustPlatform.buildRustPackage
rec {
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
  ];

  meta = with lib; {
    homepage = "https://github.com/LuckyTurtleDev/mstickereditor";
    description = "Import sticker packs from telegram, to be used at the Maunium sticker picker for Matrix";
    license = licenses.asl20;
    maintainers = with maintainers; [ yinfeng ];
  };
}
