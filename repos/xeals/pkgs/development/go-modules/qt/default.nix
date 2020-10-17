{ stdenv
, fetchFromGitHub
, buildGoModule
, makeWrapper

, pkg-config
, qmake
}:

buildGoModule rec {
  pname = "go-qt";
  version = "20200701";

  src = fetchFromGitHub {
    owner = "therecipe";
    repo = "qt";
    rev = "7f61353ee73e225efd0b08dacf0ef32f41285c71";
    sha256 = "1qwyi3rr6x49w2cbxhsyg3sbyxib7l08g6j6z1mb5w22bdgmcy7c";
  };

  vendorSha256 = "00wghn93xz240ddj47b8mkbx3cg7c0486igp6vv0x9r6ylhywsm6";
  subPackages = [ "cmd/..." ];

  nativeBuildInputs = [ makeWrapper ];

  # Fixes inconsistent vendoring.
  postPatch = ''
    cat <<EOM >>go.mod
    require (
      github.com/therecipe/env_darwin_amd64_513 v0.0.0-20190626001412-d8e92e8db4d0
      github.com/therecipe/env_linux_amd64_513 v0.0.0-20190626000307-e137a3934da6
      github.com/therecipe/env_windows_amd64_513 v0.0.0-20190626000028-79ec8bd06fb2
      github.com/therecipe/env_windows_amd64_513/Tools v0.0.0-20190626000028-79ec8bd06fb2
      github.com/therecipe/qt/internal/binding/files/docs/5.12.0 v0.0.0-20200904063919-c0c124a5770d
      github.com/therecipe/qt/internal/binding/files/docs/5.13.0 v0.0.0-20200904063919-c0c124a5770d
    )
    EOM
  '';

  doCheck = true;
  checkPhase = ''
    $GOPATH/bin/qtsetup test
  '';

  postFixup = ''
    for bin in $out/bin/*; do
      wrapProgram $bin \
        --set QT_PKG_CONFIG true \
        --prefix PATH : ${pkg-config}/bin \
        --prefix PATH : ${qmake}/bin
    done
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/therecipe/qt";
    description = "Qt bindings for Go";
    license = licenses.lgpl3;
  };
}
