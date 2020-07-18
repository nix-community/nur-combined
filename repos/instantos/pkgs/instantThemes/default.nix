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
    rev = "d0435778e08465f1dba0880176a331c8bd527331";
    sha256 = "1zgzxdkp1k44m2irsjapqhwccvxillvil2a6wdvimh3792c5lzih";
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
