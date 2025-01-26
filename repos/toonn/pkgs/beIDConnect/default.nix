{ lib
, stdenv
, fetchFromGitHub
, boost
, pcsclite
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "beIDConnect";
  version = "2.10";

  src = fetchFromGitHub {
    owner = "Fedict";
    repo = "fts-beidconnect";
    tag = "${version}";
    hash = "sha256-xkBldXOlgLMgrvzm7ajXzJ92mpXrxHD1RX4DeBxU3kk=";
  };

  nativeBuildInputs = [ boost pcsclite pkg-config ];

  buildPhase = ''
    runHook preBuild

    cd linux/
    make beidconnect

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D --target-directory=$out/bin/ beidconnect
    mkdir -p $out/lib/mozilla/native-messaging-hosts/
    $out/bin/beidconnect -setup $out/bin \
      $out/lib/mozilla/native-messaging-hosts/

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/Fedict/fts-beidconnect";
    description = "Supporting software for https://sign.belgium.be/";
    license = { free = false;
                fullName = "BeIDConnect Software License";
                redistributable = true;
                spdxId = "LicenseRef-BeIDConnectSoftwareLicense";
                url = "https://github.com/Fedict/fts-beidconnect/blob/master/LICENSE/license_nl.pdf";
              };
    maintainers = with lib.maintainers; [ toonn ];
    mainProgram = "beidconnect";
    platforms = lib.platforms.linux;
  };
}
