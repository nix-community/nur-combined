{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "rime-prelude";
  version = "0-unstable-2024-05-19";

  src = fetchFromGitHub {
    owner = "rime";
    repo = "rime-prelude";
    rev = "3803f09458072e03b9ed396692ce7e1d35c88c95";
    hash = "sha256-qLxkijfB/btd2yhUMbxmoNx6fKxpKYHBZoE7YEUKIu4=";
  };
  installPhase = ''
    mkdir -p $out/share/rime-data/
    cp *.yaml $out/share/rime-data/
  '';
}
