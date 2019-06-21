{ lib, buildGoModule, fetchFromGitHub }:

let version = "0.7.0"; in

buildGoModule {
  pname = "helmfile";
  inherit version;

  src = fetchFromGitHub {
    owner = "instrumenta";
    repo = "conftest";
    rev = "v${version}";
    sha256 = "0qq2kp9h91rirlhml5vyzmi7rd4v3pkqjk2bn7mvdn578jnwww24";
  };

  buildFlagsArray = ''
    -ldflags=
        -X main.version=${version}
        -X main.commit=751e61129f5703d9240d4c815bd8b79b5b4c6990
        -X main.date=2019-06-16
  '';

  goPackagePath = "github.com/instrumenta/confest";

  modSha256 = "1w3bik5i09znl56f0wqpkjs325faqvcnb0h6ng8ni6n7ygsrcfj1";

  meta = with lib; {
    description = "Write tests against structured configuration data";
    homepage = https://github.com/instrumenta/conftest;
    license = licenses.asl20;
    maintainers = with maintainers; [ yurrriq ];
    platforms = platforms.all;
  };
}
