{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "gosuki";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "blob42";
    repo = "gosuki";
    tag = "v${version}";
    hash = "sha256-7//uQwUhpzBQueLEZccW8D3eGiGcuzYr7jy4Udr1tdA=";
  };

  proxyVendor = true;

  vendorHash = "sha256-k71L+Gil9FdfKnpl9YfeA7me+PUHTfAlqqco9g2/Cl8=";

  meta = {
    description = "Extension-free, multi-browser, real time, cloudless bookmark manager";
    homepage = "https://github.com/blob42/gosuki";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [renesat];
  };
}
