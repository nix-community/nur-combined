{ lib, buildGoModule, sources }:
let
  pname = "pg_tileserv";
  date = lib.substring 0 10 sources.pg-tileserv.date;
  version = "unstable-" + date;
in
buildGoModule {
  inherit pname version;
  src = sources.pg-tileserv;

  vendorSha256 = "1wpzj6par25z7cyyz6p41cxdll4nzb0jjdl1pffgawiy9z7j17vb";

  meta = with lib; {
    inherit (sources.pg-tileserv) description homepage;
    license = licenses.asl20;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
