{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "gosuki";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "blob42";
    repo = "gosuki";
    tag = "v${version}";
    hash = "sha256-F3lSymL2d/ABdDcDDb2jjXJtPAYcRZ2msJCbMgNvXdc=";
  };

  proxyVendor = true;

  vendorHash = "sha256-0Z6ozWWwlRVqp5MKzYHuGjFNQkf42p/ddRb3NwmMiu8=";

  meta = {
    description = "Extension-free, multi-browser, real time, cloudless bookmark manager";
    homepage = "https://github.com/blob42/gosuki";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [renesat];
  };
}
