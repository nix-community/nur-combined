{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "html-to-markdown";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "JohannesKaufmann";
    repo = "html-to-markdown";
    rev = "v${version}";
    hash = "sha256-JmSSQmha3xMzUonSU03ChwldSNbID40Wyp9S6V1E0Y8=";
  };

  vendorHash = "sha256-6QNnw22KRltVmVEeIn0lec7Moo/Cub3rhwtvIwODw2w=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Convert HTML to Markdown. Even works with entire websites and can be extended through rules";
    homepage = "https://github.com/JohannesKaufmann/html-to-markdown";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ meain ];
    mainProgram = "html-to-markdown";
  };
}
