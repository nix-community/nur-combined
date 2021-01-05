{ lib, buildGoModule, sources }:

buildGoModule {
  pname = "odict-unstable";
  version = lib.substring 0 10 sources.odict.date;

  src = sources.odict;

  vendorSha256 = "1n07b9dclsyc0m50lifigm90k3l6s1kbx6fln4gzp4crn0axh0gs";

  meta = with lib; {
    inherit (sources.odict) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
