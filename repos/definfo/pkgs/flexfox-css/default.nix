{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "flexfox-css";
  version = "3.7.3";

  src = fetchFromGitHub {
    owner = "yuuqilin";
    repo = "FlexFox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6qHVx73DIX9Ctpu0zFkLUu8OB3jO54DlQTwGYl9oVpI=";
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
