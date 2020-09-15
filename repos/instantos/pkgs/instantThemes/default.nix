{ lib
, stdenv
, fetchFromGitHub
, Paperbash
}:
stdenv.mkDerivation {

  pname = "instantThemes";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantTHEMES";
    rev = "cd019c00aee46792a9af55f67bd4690bac0af98d";
    sha256 = "1403hdwbac6syvzqq8v9glw96h9jaqi650sdciisqlpa3m3fg5ib";
    name = "instantOS_instantThemes";
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
    description = "instantOS Themes";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantTHEMES";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
