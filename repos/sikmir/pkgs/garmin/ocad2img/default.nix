{ lib, stdenv, buildPerlPackage, fetchwebarchive, unzip, dos2unix, cgpsmapper, ocad2mp, ModulePluggable, Tk }:

buildPerlPackage {
  pname = "ocad2img";
  version = "2009-10-11";

  src = fetchwebarchive {
    url = "http://worldofo.com/div/ocad2img.zip";
    timestamp = "20150326063156";
    sha256 = "1w68jww1kyy2cdzc8b69pca5w05gxj8q3ap5q0ff10ix0sfcm0mn";
  };

  sourceRoot = ".";

  outputs = [ "out" ];

  nativeBuildInputs = [ unzip dos2unix ];

  propagatedBuildInputs = [ ModulePluggable Tk ];

  postPatch = ''
    substituteInPlace ocad2img.pl \
      --replace "cgpsmapper" "${cgpsmapper}/bin/cgpsmapper-static" \
      --replace "ocad2mp.exe" "${ocad2mp}/bin/ocad2mp" \
      --replace "symbols.txt" "$out/share/ocad2img/symbols.txt" \
      --replace "use Win32" "#use Win32" \
      --replace "require \"unicore/lib/gc_sc" "#require \"unicore/lib/gc_sc"
  '';

  preConfigure = ''
    dos2unix ocad2img.pl
    patchShebangs .
    touch Makefile.PL
  '';

  installPhase = ''
    install -Dm755 ocad2img.pl $out/bin/ocad2img
    install -Dm644 symbols.txt -t $out/share/ocad2img
    install -dm755 $out/lib/perl5/site_perl
    cp -r Convert $out/lib/perl5/site_perl
  '';

  meta = with lib; {
    description = "Converter from OCAD map format to Garmin format";
    homepage = "http://news.worldofo.com/2009/10/11/howto-convert-any-orienteering-map-to-a-garmin-map/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
