{ stdenv, buildGoModule, fetchFromGitHub, makeWrapper, kubectl }:

buildGoModule rec {
  pname = "kubefwd";
  version = "1.8.3";

  src = fetchFromGitHub {
    owner = "txn2";
    repo = "kubefwd";
    rev = "v${version}";
    sha256 = "0kh4dmjd91lxa2i5mdm667plhincgz2r686841dazvq4r2z7vb65";
  };

  modSha256 = "1j46y80s2nihzhmqv7balxxl97m4vgnsgnsl0n1w3xmg4yahfm7d";

  nativeBuildInputs = [ makeWrapper ];

  buildFlagsArray = ''
    -ldflags=
      -X main.Version=${version}
  '';

  postInstall = ''
    wrapProgram "$out/bin/kubefwd" \
      --prefix PATH : ${stdenv.lib.makeBinPath [ kubectl ]}
  '';

  meta = with stdenv.lib; {
    description = "Bulk port forwarding Kubernetes services for local development";
    homepage = https://github.com/txn2/kubefwd;
    license = licenses.asl20;
    maintainers = with maintainers; [ yurrriq ];
    platforms = platforms.unix;
  };
}
