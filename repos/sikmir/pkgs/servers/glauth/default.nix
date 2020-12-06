{ lib, buildGoModule, go-bindata, sources }:

buildGoModule {
  pname = "glauth-unstable";
  version = lib.substring 0 10 sources.glauth.date;

  src = sources.glauth;

  vendorSha256 = "18inm0s9mww7c19z9alnvy0g80d3laxh4lwbgzkcc8kf9zg25149";

  nativeBuildInputs = [ go-bindata ];

  buildFlagsArray = [ "-ldflags=-X main.GitCommit=${sources.glauth.rev}" ];

  preBuild = "go-bindata -pkg=assets -o=pkg/assets/bindata.go assets";

  doCheck = false;

  meta = with lib; {
    inherit (sources.glauth) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
