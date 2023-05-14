{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "emitter";
  version = "3.0";

  src = fetchFromGitHub {
    owner = "emitter-io";
    repo = "emitter";
    rev = "v${version}";
    hash = "sha256-oLTAWw6JgW8yF+pvAhQtaATvOpA/8tKN+pGZQXYYv6c=";
  };

  postPatch = ''
    substituteInPlace internal/provider/monitor/statsd_test.go \
      --replace "TestStatsd_Configure" "SkipStatsd_Configure"
  '';

  vendorHash = "sha256-5BeYdznpopkz4XhdKu5MXZ5qhpHntAe+h17XsKLrGd0=";

  preCheck = ''
    export HOME=$TMPDIR
  '';

  doCheck = false;

  meta = with lib; {
    description = "High performance, distributed and low latency publish-subscribe platform";
    homepage = "https://emitter.io/";
    license = licenses.agpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
