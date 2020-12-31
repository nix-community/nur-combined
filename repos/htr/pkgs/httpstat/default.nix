{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "httpstat";

  src = fetchFromGitHub {
    owner = "htr";
    repo = "httpstat";
    rev = "13a98068213cc32c177bcea0b89a740deec89ed9";
    sha256 = "08hdvx5wr03d26rdbmbk0i1myrqsdrxbimskaz5w7wqria2zp0n3";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp httpstat.sh $out/bin/httpstat
    chmod +x $out/bin/httpstat
  '';

  meta = with lib; {
    description = "Prettier curl stats";
    homepage = "https://github.com/htr/httpstat";
    license = licenses.mit;
    maintainers = with maintainers; [ htr ];
  };

}

