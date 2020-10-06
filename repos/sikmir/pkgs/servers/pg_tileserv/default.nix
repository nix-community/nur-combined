{ lib, buildGoModule, sources }:
let
  pname = "pg_tileserv";
  date = lib.substring 0 10 sources.pg-tileserv.date;
  version = "unstable-" + date;
in
buildGoModule {
  inherit pname version;
  src = sources.pg-tileserv;

  vendorSha256 = "1zim7h6nqz61rwzv4qf5hd26w9zk91cqx8b50i3bbd01iv4nd9g6";

  doCheck = false;

  meta = with lib; {
    inherit (sources.pg-tileserv) description homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
