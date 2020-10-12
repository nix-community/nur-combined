{ stdenv, fetchfromgh, undmg }:
let
  pname = "goldencheetah";
  version = "3.5";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchfromgh {
    owner = "GoldenCheetah";
    repo = "GoldenCheetah";
    version = "V${version}";
    name = "GoldenCheetah_v${version}_64bit_MacOS.dmg";
    sha256 = "0alg0a071lpkx0v3qqkqbb93vh1nsb3d7czxl9m15v17akp8nl82";
  };

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/Applications/GoldenCheetah.app
    cp -R . $out/Applications/GoldenCheetah.app
  '';

  meta = with stdenv.lib; {
    description = "Performance software for cyclists, runners and triathletes";
    homepage = "https://www.goldencheetah.org/";
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
