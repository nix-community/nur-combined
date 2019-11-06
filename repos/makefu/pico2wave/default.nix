{ stdenv, lib, fetchurl
, popt
, libredirect
, dpkg
, makeWrapper
, autoPatchelfHook
, ...
}:
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=svox-pico-bin
let
  pkgrel="8";
  _arch = "amd64";
in
stdenv.mkDerivation rec {
  name = "pico2wave"; # svox-pico-bin
  version = "1.0+git20130326";
  srcs = [
    (fetchurl { url = "http://mirrors.kernel.org/ubuntu/pool/multiverse/s/svox/libttspico0_${version}-${pkgrel}_${_arch}.deb"; sha256 = "0b8r7r8by5kamnm960bsicimnj1a40ghy3475nzy1jvwj5xgqhrj"; })
    (fetchurl { url = "http://mirrors.kernel.org/ubuntu/pool/multiverse/s/svox/libttspico-dev_${version}-${pkgrel}_${_arch}.deb"; sha256 = "1knjiwi117h02nbf7k6ll080vl65gxwx3rpj0fq5xkvxbqpjjbvz"; })
    (fetchurl { url = "http://mirrors.kernel.org/ubuntu/pool/multiverse/s/svox/libttspico-data_${version}-${pkgrel}_all.deb"; sha256 = "0k0x5jh5qzzasrg766pfmls3ksj18wwdbssysvpxkq98aqg4fgmx"; })
    (fetchurl { url = "http://mirrors.kernel.org/ubuntu/pool/multiverse/s/svox/libttspico-utils_${version}-${pkgrel}_${_arch}.deb"; sha256 = "11yk25fh4n7qz4xjg0dri68ygc3aapj1bk9cvhcwkfvm46j5lrjv"; })
  ] ;

  nativeBuildInputs = [ dpkg makeWrapper autoPatchelfHook ];

  dontBuild = true;

  buildInputs = [ popt ];

  unpackPhase = lib.concatMapStringsSep ";" (src: "dpkg-deb -x ${src} .") srcs;

  installPhase = ''
    mkdir -p $out
    cp -r usr/. $out/

    mv $out/lib/*-linux-gnu/* $out/lib/
    rmdir $out/lib/*-linux-gnu

    wrapProgram "$out/bin/pico2wave" \
      --set LD_PRELOAD "${libredirect}/lib/libredirect.so" \
      --set NIX_REDIRECTS /usr/share/pico/lang=$out/share/pico/lang
  '';

  meta = with stdenv.lib; {
    description = "Text-to-speech engine";
    homepage = https://android.googlesource.com/platform/external/svox;
    platforms = platforms.linux;
    license = licenses.asl20;
    maintainers = with maintainers; [ abbradar ];
  };
}
