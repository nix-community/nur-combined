{
  sources,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  inherit (sources.ncmdump-rs) pname version src;

  cargoHash = "sha256-7Mqa0aa3Uv8JnviowmLJ6HgAQw+TmnW72CmDa1HyFZM=";
  useFetchCargoVendor = true;

  meta = {
    changelog = "https://github.com/iqiziqi/ncmdump.rs/releases/tag/${version}";
    mainProgram = "ncmdump";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "NetEase Cloud Music copyright protection file dump by rust";
    homepage = "https://github.com/iqiziqi/ncmdump.rs";
    license = lib.licenses.mit;
  };
}
