{
  lib,
  fetchFromGitHub,
  buildGoModule,
  ...
}: let
  pname = "g90updatefw";
  version = "1.5";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "DaleFarnsworth";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-jTeEpUHEuFRGmIo70f0nVg5eQ0MIOhamsd/jACkkhfU=";
    };

    vendorSha256 = null;

    meta = with lib; {
      description = "Xiegu G90 and Xiego G106 Firmware Updater";
      homepage = "https://github.com/DaleFarnsworth/${pname}";
      changelog = "https://github.com/DaleFarnsworth/${pname}/releases/tag/v${version}";
      license = licenses.gpl3;
      maintainers = [maintainers.etu];
      platforms = platforms.all;
    };
  }
