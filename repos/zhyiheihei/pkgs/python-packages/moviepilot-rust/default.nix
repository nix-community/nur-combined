{
  lib,
  stdenv,
  sources,
  buildPythonPackage,
}:
let
  arch =
    if stdenv.hostPlatform.isAarch64 then
      "aarch64"
    else if stdenv.hostPlatform.isx86_64 then
      "x86_64"
    else
      throw "unsupported system: ${stdenv.hostPlatform.system}";
  source = sources."moviepilot-rust-${arch}";
in
buildPythonPackage rec {
  pname = "moviepilot-rust";
  inherit (source) version;
  src = source.src;

  format = "wheel";

  pythonImportsCheck = [ "moviepilot_rust" ];

  meta = {
    description = "Rust acceleration helpers for MoviePilot";
    homepage = "https://github.com/jxxghp/MoviePilot";
    license = lib.licenses.gpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
