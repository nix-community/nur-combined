{ lib
, stdenv
, sources
}:


stdenv.mkDerivation {
  name = "httpstat";

  src = sources.httpstat;

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

