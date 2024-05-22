{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "emitter";
  version = "3.1";

  src = fetchFromGitHub {
    owner = "emitter-io";
    repo = "emitter";
    rev = "v${version}";
    hash = "sha256-eWBgRG0mLdiJj1TMSAxYPs+8CqLNaFUOW6/ghDn/zKE=";
  };

  vendorHash = "sha256-6K9KAvb+05nn2pFuVDiQ9IHZWpm+q01su6pl7CxXxBY=";

  preCheck = ''
    export HOME=$TMPDIR
  '';

  doCheck = false;

  checkFlags = [ "-skip=TestStatsd_Configure" ];

  meta = with lib; {
    description = "High performance, distributed and low latency publish-subscribe platform";
    homepage = "https://emitter.io/";
    license = licenses.agpl3Plus;
    maintainers = [ maintainers.sikmir ];
  };
}
