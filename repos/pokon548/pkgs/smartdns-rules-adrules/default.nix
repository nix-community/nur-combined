{ stdenv
, lib
, fetchurl
}:
stdenv.mkDerivation {
  pname = "smartdns-rules-adrules";
  version = "20231115";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/Cats-Team/AdRules/f33359a5f2555c4a36df21e9d25af05b24f4fd08/smart-dns.conf";
    sha256 = "sha256-8VATGCvCl90GZPtiBBmXxhXHfu852+qqHxve+MOLzlQ=";
  };

  unpackPhase = ''
    runHook preUnpack
  '';

  installPhase = ''
    install -Dm644 $src $out/adrules-smartdns.conf
  '';

  meta = with lib; {
    description = "List for blocking ads in the Chinese region";
    homepage = "https://adrules.top";
    license = licenses.wtfpl;
  };
}