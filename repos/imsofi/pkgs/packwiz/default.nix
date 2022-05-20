{ stdenv
, fetchFromGitHub
, buildGo118Module
, lib
}:

buildGo118Module rec {
  pname = "packwiz";
  version = "2073e44";

  src = fetchFromGitHub {
    owner = "packwiz";
    repo = pname;
    rev = "2073e4475e94772f885fffa73f996876e6fa40db";
    sha256 = "sha256-orKJ/IzL9Txuo6XjS2KUqJyE/MugYPlTcjUIWcFKfxw=";
  };

  vendorSha256 = "sha256-M9u7N4IrL0B4pPRQwQG5TlMaGT++w3ZKHZ0RdxEHPKk=";

  meta = with lib; {
    description = "A command line tool for editing and distributing Minecraft modpacks";
    homepage = "https://github.com/packwiz/packwiz";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
