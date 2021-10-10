{ stdenv, lib, fetchurl, autoPatchelfHook, dpkg, awscli2 }:
stdenv.mkDerivation rec {
  pname = "ssm-session-manager-plugin";
  version = "1.2.245.0";

  src = fetchurl {
    url =
      "https://s3.amazonaws.com/session-manager-downloads/plugin/${version}/ubuntu_64bit/session-manager-plugin.deb";
    sha256 = "sha256-8cA9KqrZ+J9z/HDxwc3vDih3oDuGzKPItcl5ksY0REk=";
  };

  nativeBuildInputs = [ autoPatchelfHook dpkg ];

  buildInputs = [ awscli2 ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase =
    "install -m755 -D usr/local/sessionmanagerplugin/bin/session-manager-plugin $out/bin/session-manager-plugin";

  meta = with lib; {
    homepage =
      "https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html";
    description = "Amazon SSM Session Manager Plugin (using awscli2)";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
    maintainers = with maintainers; [ mbaillie ];
  };
}
