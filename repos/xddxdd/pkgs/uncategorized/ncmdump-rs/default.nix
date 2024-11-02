{
  sources,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  inherit (sources.ncmdump-rs) pname version src;

  cargoHash = "sha256-fT4hYvfenykMUc4+Y7J6LQbTKEopSGutBKD+wZy2Uzg=";

  meta = {
    mainProgram = "ncmdump";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "NetEase Cloud Music copyright protection file dump by rust";
    homepage = "https://github.com/iqiziqi/ncmdump.rs";
    license = lib.licenses.mit;
  };
}
