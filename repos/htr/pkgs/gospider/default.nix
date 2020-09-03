{ buildGoModule
, fetchFromGitHub
, lib
, sources
}:

buildGoModule rec {
  pname = "gospider";
  version = "1.1.2";

  src = sources.gospider;

  vendorSha256 = "0j6pngcdjral95zjxicq2d94xigwjk1vl1birq84j25kjr27yb2n";

  doCheck = false;

  meta = with lib; {
    description = "Fast web spider written in Go";
    homepage = "https://github.com/jaeles-project/gospider";
    license = licenses.mit;
    maintainers = with maintainers; [ htr ];
  };
}
