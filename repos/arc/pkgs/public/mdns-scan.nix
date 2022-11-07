{ stdenv, fetchFromGitHub, lib }: stdenv.mkDerivation rec {
  pname = "mdns-scan";
  version = "2020-07-15";
  src = fetchFromGitHub {
    owner = "alteholz";
    repo = pname;
    rev = "9c307d81d82812e423664e4ebe135f429d995ac8";
    sha256 = "sha256-+rbxmzHlKZVH+VDxNqzhKzPOlOZMju+KEoRVGzbXNjg=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm0755 -t $out/bin $pname

    runHook postInstall
  '';
}
