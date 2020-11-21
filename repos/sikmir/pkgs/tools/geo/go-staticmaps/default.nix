{ lib, buildGoModule, sources }:

buildGoModule {
  pname = "go-staticmaps";
  version = lib.substring 0 10 sources.go-staticmaps.date;

  src = sources.go-staticmaps;

  vendorSha256 = "13zp6fxjmaxnn2ald8n9gjlx225w9bvq1xwibns1bdsq2c6gyffz";

  meta = with lib; {
    inherit (sources.go-staticmaps) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
