{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: rec {
  name = "rime-kaomoji";

  src = fetchFromGitHub {
    owner = "Freed-Wu";
    repo = "rime-kaomoji";
    rev = "e2b64996bf26e409466a1de8a904364b634e6307";
    hash = "sha256-Zf52XdjKWSzlGfS1c9fZ7/xjPK8gJKZ5JB0Oj0B031k=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm0644 kaomoji_suggestion.yaml -t $out/share/rime-data
    install -Dm0644 opencc/* -t $out/share/rime-data/opencc
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/rime-kaomoji";
    description = "Kaomoji support for rime";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
})
