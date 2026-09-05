{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  curl,
  jq,
  chafa,
}:
stdenv.mkDerivation rec {
  pname = "waifufetch";
  version = "main";

  src = fetchFromGitHub {
    owner = "JGH0";
    repo = "waifufetch";
    rev = "${version}";
    sha256 = "sha256-4PVlNJnkO0eVTclwfg6LfBAsAnWK6W9gj+gFKCAY6P8=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 waifu $out/bin/waifu
    install -Dm755 waifufetch $out/bin/waifufetch
    install -Dm644 libwaifu.sh $out/bin/libwaifu.sh

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/waifu --prefix PATH : ${
      lib.makeBinPath [
        curl
        jq
        chafa
      ]
    }
    wrapProgram $out/bin/waifufetch --prefix PATH : ${
      lib.makeBinPath [
        curl
        jq
        chafa
      ]
    }
  '';

  meta = with lib; {
    description = "System info with a random waifu decoration";
    homepage = "https://github.com/JGH0/waifufetch";
    changelog = "https://github.com/JGH0/waifufetch/releases";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "waifufetch";
  };
}
