final: prev:
{
  upwork = prev.upwork.overrideAttrs ( old: rec {
    src = prev.requireFile {
      name = "${old.pname}_${old.version}_amd64.deb";
      url = "https://www.upwork.com/ab/downloads/os/linux/";
      sha256 = "c3e1ecf14c99596f434edf93a2e08f031fbaa167025d1280cf19f68b829d6b79";
    };
  } );
  upwork-download = final.upwork;
}
