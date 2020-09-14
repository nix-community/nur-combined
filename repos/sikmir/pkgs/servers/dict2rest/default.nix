{ lib, buildGoPackage, sources }:
let
  pname = "dict2rest";
  date = lib.substring 0 10 sources.dict2rest.date;
  version = "unstable-" + date;
in
buildGoPackage {
  inherit pname version;
  src = sources.dict2rest;

  goPackagePath = "github.com/felix/go-dict2rest";

  meta = with lib; {
    inherit (sources.dict2rest) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
