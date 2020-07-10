{ lib, buildGoModule, go-bindata, sources }:

buildGoModule {
  pname = "glauth";
  version = lib.substring 0 7 sources.glauth.rev;
  src = sources.glauth;

  vendorSha256 = "18inm0s9mww7c19z9alnvy0g80d3laxh4lwbgzkcc8kf9zg25149";

  nativeBuildInputs = [ go-bindata ];

  buildFlagsArray = ''
    -ldflags=
      -X main.GitCommit=${sources.glauth.rev}
  '';

  preBuild = ''
    go-bindata -pkg=assets -o=pkg/assets/bindata.go assets
  '';

  meta = with lib; {
    inherit (sources.glauth) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
