{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "flexfox-css";
  version = "3.5.5";

  src = fetchFromGitHub {
    owner = "yuuqilin";
    repo = "FlexFox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PesIIw5PUj8IvD5FQw1UBjWPGbivUdcJIrxA3EjZ3Pg=";
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
