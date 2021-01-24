{ lib, buildGoPackage, sources }:

buildGoPackage {
  pname = "dict2rest";
  version = lib.substring 0 10 sources.dict2rest.date;

  src = sources.dict2rest;

  goPackagePath = "github.com/felix/go-dict2rest";

  meta = with lib; {
    inherit (sources.dict2rest) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
