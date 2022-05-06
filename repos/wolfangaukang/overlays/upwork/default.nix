self: super:
{
  # In case you need to only replace the version.
  # You will need to get the URL and SHA256 from https://www.upwork.com/ab/downloads/
  #   from Debian-based 64-bit Standard.
  #upwork = super.upwork.overrideAttrs ( old: rec {
  #  version = "5.6.7.13";

  #  src = super.fetchurl {
  #    url = "https://upwork-usw2-desktopapp.upwork.com/binaries/v5_6_7_13_9f0e0a44a59e4331/upwork_${version}_amd64.deb";
  #    sha256 = "f1d3168cda47f77100192ee97aa629e2452fe62fb364dd59ad361adbc0d1da87";
  #  };
  #});

  # In case only changing the version does not work, you will need to tweak the
  #   package file.
  upwork = super.callPackage ../pkgs/upwork { };
}
