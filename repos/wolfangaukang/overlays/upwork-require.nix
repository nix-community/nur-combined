final: prev:
{
  upwork = prev.upwork.overrideAttrs ( old: rec {
    src = prev.requireFile {
      name = "${old.pname}_5.6.10.23_amd64.deb";
      url = "https://www.upwork.com/ab/downloads/os/linux/";
      sha256 = "bda27388df444e291842cc306b719d7e91836ad172b196689d108d8f287dc89e";
    };
  } );
  upwork-download = final.upwork;
}
