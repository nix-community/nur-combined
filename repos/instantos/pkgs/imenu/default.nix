{ lib
, stdenv
, fetchFromGitHub
, instantMenu
}:
stdenv.mkDerivation {

  pname = "imenu";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "imenu";
    rev = "b9d98c39b91d4f962614564f41bcee82ae81cff8";
    sha256 = "03l6vn6wvg1d24gyw4z2w10ccsk307d3pg6ywz983cj0llcw4zl8";
    name = "instantOS_imenu";
  };

  propagatedBuildInputs = [
    instantMenu
  ];

  installPhase = ''
    install -Dm 555 imenu.sh $out/bin/imenu
  '';

  meta = with lib; {
    description = "instantOS imenu";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/imenu";
    maintainers = [ "con-f-use <con-f-use@gmx.net" ];
    platforms = platforms.linux;
  };
}
