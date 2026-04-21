{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot-audio.yazi";
  version = "0-unstable-2026-04-20";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "e2b07341a0569d511a11c51653b1b1dd4bcf3141";
    hash = "sha256-lxttwyDwGsC77XUtLeACMrRznC54NitcJNKU1u9g/gE=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    # keep-sorted start
    description = "audio metadata";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/spot-audio.yazi";
    license = lib.licenses.gpl3Only;
    # keep-sorted end
  };
}
