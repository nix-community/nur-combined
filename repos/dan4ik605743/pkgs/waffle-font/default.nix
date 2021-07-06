{ stdenv
, lib
, fetchgit
, mkfontscale
}:

stdenv.mkDerivation 
{
  name = "waffle-font";
  src = fetchgit 
  {
    url = "https://github.com/addy-dclxvi/bitmap-font-collections";
    sha256 = "sha256-a0MA2jIH7J4Btm8JBi7EHjI3Pt/ZaCZK6JqNH7PLSvM=";
  };
  dontUnpack = true;
  nativeBuildInputs =
  [
    mkfontscale
  ];
  installPhase = 
  ''
    mkdir -p $out/share/fonts/
    cp $src/waffle-10.bdf $out/share/fonts/
    cd "$out/share/fonts"
    mkfontdir
    mkfontscale
  '';
  meta = with lib; {
    description = "bitmap-font";
    homepage = "https://github.com/addy-dclxvi/bitmap-font-collections";
    license = licenses.mit;
    maintainers = with maintainers; [ dan4ik605743 ];
    platforms = platforms.linux;
  };
}
