{ lib, buildGoModule, sources }:
let
  pname = "pg_featureserv";
  date = lib.substring 0 10 sources.pg-featureserv.date;
  version = "unstable-" + date;
in
buildGoModule {
  inherit pname version;
  src = sources.pg-featureserv;

  vendorSha256 = "1jqrkx850ghmpnfjhqky93r8fq7q63m5ivs0lzljzbvn7ya75f2r";

  meta = with lib; {
    inherit (sources.pg-featureserv) description homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
