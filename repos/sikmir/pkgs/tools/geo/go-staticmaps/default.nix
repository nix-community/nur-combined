{ lib, buildGoModule, sources }:

buildGoModule {
  pname = "go-staticmaps";
  version = lib.substring 0 10 sources.go-staticmaps.date;

  src = sources.go-staticmaps;

  vendorSha256 = "0xv9s53vw2m8qn65gn4jp3h42l31llisvmhlk9jsj6qs2ccqqxqw";

  meta = with lib; {
    inherit (sources.go-staticmaps) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
