{ fetchurl, stdenv, p7zip, libX11, libXext, alsaLib, freetype, lv2, libjack2 }:

let 
  version = "6.4.1";
  urlVersion = builtins.replaceStrings ["."] [""] version;
  url = "https://www.pianoteq.com/try?file=pianoteq_stage_linux_trial_v${urlVersion}.7z";
  re = ".*([A-Za-z0-9]{128}).*";
  downstr = with builtins; head (match re (readFile (builtins.fetchurl url)));
  archdir = if stdenv.isAarch64 then
    "arm"
  else if stdenv.isx86_64 then
    "amd64"
  else if stdenv.isi686 then
    "i386"
  else
    throw "Unsupported architecture";
in

stdenv.mkDerivation rec {
  name = "pianoteq-stage-${version}";

  nativeBuildInputs = [ p7zip ];

  buildPhase = ":";
  
  src = fetchurl {
    url = "https://www.pianoteq.com/try?q=${downstr}";
    sha256 = "0fvipijnp4xmw3k03n03r1rzasl4jhww0bd427qwyhvdxmw34qbx";
    name = "${name}.7z";
  };
  
  libPath = stdenv.lib.makeLibraryPath [ 
    libX11 libXext alsaLib freetype lv2 libjack2 stdenv.cc.cc 
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp "${archdir}/Pianoteq 6 STAGE" "$out/bin/pianoteq-stage"
    patchelf --set-interpreter "$(< $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath $libPath \
      "$out/bin/pianoteq-stage"

    mkdir -p "$out/lib/lv2/Pianoteq 6.lv2"
    cp -a "${archdir}/Pianoteq 6 STAGE.lv2/"* "$out/lib/lv2/Pianoteq 6.lv2/"
  '';
  
  fixupPhase = ":";

  meta = with stdenv.lib; {
    description = "Virtual piano instrument using physical modelling synthesis";
    homepage = https://www.pianoteq.com/;
    license = licenses.unfree;
    maintainers = with maintainers; [ dywedir ];
    platforms = platforms.linux;
  };
}
