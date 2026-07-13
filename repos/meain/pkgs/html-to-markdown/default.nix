{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "html-to-markdown";
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "JohannesKaufmann";
    repo = "html-to-markdown";
    rev = "v${version}";
    hash = "sha256-Ay2ICo+zhVDLX8fpAfc+8/YrLGRCD9swDjAQHiA9+Eg=";
  };

  vendorHash = "sha256-/7Rm01pzjIZ31wxH5mjqGpojFX5GZknjRnFKPrr4JF4=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Convert HTML to Markdown. Even works with entire websites and can be extended through rules";
    homepage = "https://github.com/JohannesKaufmann/html-to-markdown";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ meain ];
    mainProgram = "html-to-markdown";
  };
}
