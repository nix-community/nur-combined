{ stdenv, fetchurl }:

let
  platform = if stdenv.isDarwin then "darwin" else "linux";
  version = "2.8.0";
  linuxSha = "1vhnq5vyyp4hms7frgm917fmvhwbiqs30jiqpd5f9iz28rx33175";
  darwinSha = "1b5q1v63735ncs186r6hyivr8nla19wlwcf8fqdf590g308ny5yd";
in stdenv.mkDerivation {
  name = "codeship-jet";
  inherit version;

  src = fetchurl {
    url = "https://s3.amazonaws.com/codeship-jet-releases/${version}/jet-${platform}_amd64_${version}.tar.gz";
    sha256 = if stdenv.isDarwin then darwinSha else linuxSha;
  };

  unpackPhase = ''
    tar xf $src
  '';
  installPhase = ''
    mkdir -p $out/bin
    mv jet $out/bin/
    chmod +x $out/bin/jet
  '';
  
  meta = with stdenv.lib; {
    description = "A closed-source cli for CodeShip CI";
    platforms = platforms.all;
  };
}
