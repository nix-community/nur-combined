{ stdenv, fetchfromgh, unzip }:
let
  pname = "Amethyst";
  version = "0.15.4";
  sha256 = "16n5vdyjs6m4saqibv3fb420w6x83lsiw182qm3prnilh4q9qld3";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchfromgh {
    owner = "ianyh";
    repo = pname;
    version = "v${version}";
    name = "Amethyst.zip";
    inherit sha256;
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  preferLocalBuild = true;

  meta = with stdenv.lib; {
    description = "Automatic tiling window manager for macOS à la xmonad";
    homepage = "https://ianyh.com/amethyst/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
