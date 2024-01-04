{ lib, buildGoModule, fetchFromGitHub, openssl }:

buildGoModule rec {
  pname = "tootik";
  version = "0.5.11";

  src = fetchFromGitHub {
    owner = "dimkr";
    repo = "tootik";
    rev = version;
    hash = "sha256-PmBj48JoCTv1S9QjdJK34m/WBPLyXc8ewjMFEfdigAQ=";
  };

  vendorHash = "sha256-uxY+mdUm67a7dEBezs6VWcsb+RUs1zsoFeU9DXek+Lg=";

  nativeBuildInputs = [ openssl ];

  preBuild = ''
    go generate ./migrations
  '';

  meta = with lib; {
    description = "A federated nanoblogging service with a Gemini frontend";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
