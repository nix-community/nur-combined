{
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "seal_lake";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "kamchatka-volcano";
    repo = "seal_lake";
    rev = "v${version}";
    hash = "sha256-9vZOaZx9ozHOf8g4zpj2zNzZJ4c1BPHpEYq3gp7BmyE=";
  };
  installPhase = ''
    mkdir -p $out/share/$pname/cmake
    cp $pname.cmake $out/share/$pname/cmake/$pname-config.cmake
    cp CPM.cmake $out/share/$pname/cmake/CPM.cmake
  '';
}
