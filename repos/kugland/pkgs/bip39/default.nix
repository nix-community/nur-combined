{ stdenv
, lib
, pkg-config
, meson
, ninja
, libsodium
, cunit
, fetchFromGitHub
}:

stdenv.mkDerivation (final: rec {
  pname = "bip39";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "kugland";
    repo = "bip39";
    rev = "v${version}";
    hash = "sha256-CMKexq0xkAWHQ1KJnXyQxbVQHDAc6Oql73eQ4IAviCE=";
  };

  nativeBuildInputs = [ pkg-config meson ninja ];
  buildInputs = [ libsodium ];
  checkInputs = [ cunit ];

  doCheck = true;

  meta = with lib; {
    description = "Generate BIP-0039 mnemonic phrases";
    homepage = "";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ ];
  };
})
