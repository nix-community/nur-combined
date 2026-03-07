{
  lib,
  fetchFromGitHub,
  mkYaziPlugin,
}:
mkYaziPlugin rec {
  pname = "spot-image.yazi";
  version = "unstable-2026-03-06";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "0739017aa104a0473327e9eb81af267e955c9d1a";
    hash = "sha256-gn02Le02bbIwyB/mTXN0U2MEzZTtVMRVeuLeYBDT9sM=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    description = "image metadata and exif";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/spot-image.yazi";
    license = lib.licenses.gpl3Only;
  };
}
