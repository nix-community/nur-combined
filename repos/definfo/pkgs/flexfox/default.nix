{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "flexfox-css";
  version = "3.6.4";

  src = fetchFromGitHub {
    owner = "yuuqilin";
    repo = "FlexFox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sRbCI01f14fGqYfSY3mPT5LsDXa2wpsxxANTLdCyowo=";
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
