{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  version = "unstable-2020-28-07";
  pname = "hdl_dump";

  src = fetchFromGitHub {
    owner = "AKuHAK";
    repo = "hdl-dump";
    rev = "be37e112a44772a1341c867dc3dfee7381ce9e59";
    sha256 = "0akxak6hm11h8z6jczxgr795s4a8czspwnhl3swqxp803dvjdx41";
  };

  installPhase = ''
    install -Dm755 hdl_dump -t $out/bin
  '';

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "PlayStation 2 HDLoader image dump/install utility";
    platforms = platforms.linux;
    license = licenses.gpl2;
    maintainers = with maintainers; [ genesis ];
  };
}
