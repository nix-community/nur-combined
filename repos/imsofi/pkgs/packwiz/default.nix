{ stdenv
, fetchFromGitHub
, buildGo118Module
, lib
}:

buildGo118Module rec {
  pname = "packwiz";
  version = "2022-06-05";

  src = fetchFromGitHub {
    owner = "packwiz";
    repo = pname;
    rev = "d34728f3474f435ebed7e4a9c3ef1724b8a55d37";
    sha256 = "sha256-A1WZDh2zagZE+IWxTKf/DXC6DA4P5scMyLYwazUAAq4=";
  };

  vendorSha256 = "sha256-M9u7N4IrL0B4pPRQwQG5TlMaGT++w3ZKHZ0RdxEHPKk=";

  meta = with lib; {
    description = "A command line tool for editing and distributing Minecraft modpacks";
    homepage = "https://github.com/packwiz/packwiz";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
