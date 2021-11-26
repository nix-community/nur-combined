{ stdenv, lib, writeText, fetchFromGitHub }: stdenv.mkDerivation rec {
  pname = "mdloader";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "Massdrop";
    repo = "mdloader";
    rev = version;
    sha256 = "1ij0anmbaikx8vnxqgw16062hfk63lbb0h7i8582swxz7zlm457y";
  };

  installPhase = ''
    install -Dm0755 -t $out/bin build/mdloader
  '';

  meta = {
    platforms = lib.platforms.linux;
  };
}
