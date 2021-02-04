{ lib, stdenvNoCC, sources, unzip }:

stdenvNoCC.mkDerivation {
  pname = "maptourist";
  version = sources.maptourist.version;

  src = sources.maptourist;

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = "install -Dm644 *.img -t $out";

  preferLocalBuild = true;

  meta = with lib; {
    inherit (sources.maptourist) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
