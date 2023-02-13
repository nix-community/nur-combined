{ lib
, fetchFromGitHub
, buildGoModule
, makeWrapper

, go
, pkg-config
, qmake
, removeReferencesTo
}:

buildGoModule rec {
  pname = "go-qt";
  version = "20200904.gc0c124a";

  src = fetchFromGitHub {
    owner = "therecipe";
    repo = "qt";
    rev = "c0c124a5770d357908f16fa57e0aa0ec6ccd3f91";
    sha256 = "197wdh2v0g5g2dpb1gcd5gp0g4wqzip34cawisvy6z7mygmsc8rd";
  };

  # fails with `GOFLAGS=-vendor=mod -trimpath`
  allowGoReference = true;
  preFixup = ''
    find $out -type f -exec ${removeReferencesTo}/bin/remove-references-to -t ${go} '{}' +
  '';

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

  meta = with lib; {
    homepage = "https://github.com/therecipe/qt";
    description = "Qt bindings for Go";
    license = licenses.lgpl3;
    broken = true;
  };
}
