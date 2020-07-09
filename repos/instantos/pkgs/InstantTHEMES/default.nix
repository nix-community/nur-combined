{ lib
, stdenv
, fetchFromGitHub
, Paperbash
}:
stdenv.mkDerivation rec {

  pname = "InstantTHEMES";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantTHEMES";
    rev = "master";
    sha256 = "02jab5kfn9aj5rw80pijs27s7b23kx8iqjd2nn2x78mydi29clqm";
  };

  postPatch = ''
    substituteInPlace instantthemes \
      --replace "/usr/share/instantthemes" "$out/share/instantthemes" \
      --replace "/usr/share/paperbash" "${Paperbash}/share/paperbash"
    '';

  installPhase = ''
    install -Dm 555 instantthemes $out/bin/instantthemes
    mkdir -p $out/share/instantthemes
    cp -r * $out/share/instantthemes
  '';

  propagatedBuildInputs = [ Paperbash ];

  meta = with lib; {
    description = "InstantOS Themes";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantTHEMES";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
