{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "flexfox-css";
  version = "3.6.10";

  src = fetchFromGitHub {
    owner = "yuuqilin";
    repo = "FlexFox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Wvqnqo7F9stekvZ5Xjj5+r+J7CpNgj0na7M9e4GAXK8=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r $src/{chrome,Sidebery,scripts/user.js} $out

    runHook postInstall
  '';

  meta = {
    description = "A lightweight Firefox theme focused on usability, flexibility, and smooth performance";
    homepage = "https://github.com/yuuqilin/FlexFox";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [
      definfo
    ];
  };
})
