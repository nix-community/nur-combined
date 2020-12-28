{ stdenv, fetchurl }:
stdenv.mkDerivation {
  pname = "hyperspec";
  version = "7.0";
  meta = {
    description = "The Common Lisp HyperSpec";
    homepage = "http://www.lispworks.com/documentation/HyperSpec/Front/index.htm";
  };
  src = fetchurl {
    url = "http://ftp.lispworks.com/pub/software_tools/reference/HyperSpec-7-0.tar.gz";
    sha256 = "1hyphnx74d595qz692qh8fc2xk8v6zaclqhji3cdp5y6kmm6dh8s";
  };
  # we skip the unpackPhase
  unpackPhase = "true";
  installPhase = ''
      mkdir -p "$out/share/hyperspec/"
      tar -C "$out/share/hyperspec/" -xzvf $src
  '';
}
