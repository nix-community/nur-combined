{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "swipe-navigation";
  version = "1.2.8";

  src = fetchFromGitHub {
    owner = "maykar";
    repo = "lovelace-swipe-navigation";
    rev = version;
    sha256 = "1x8zs0filspxni5lyh3z8by0kjcngiirx579b651skzn7cy5jj4b";
  };

  installPhase = ''
    mkdir $out
    cp swipe-navigation.js $out/
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/maykar/lovelace-swipe-navigation";
    description = "Swipe through Lovelace views on mobile";
    license = licenses.mit;
  };
}
