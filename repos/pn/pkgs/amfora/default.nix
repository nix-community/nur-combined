{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "amfora";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "makeworld-the-better-one";
    repo = pname;
    rev = "v${version}";
    sha256 = "1z4r1yqy5nkfa7yqcsqpqfdcghw8idryzb3s6d6ibca47r0qlcvw";
  };

  # doCheck = false;

  vendorSha256 = "0xj2s14dq10fwqqxjn4d8x6zljd5d15gjbja2gb75rfv09s4fdgv";

  buildFlags = [ ];

  subPackages = [ "." ];

  meta = with stdenv.lib; {
    description = "A fancy terminal browser for the Gemini protocol.";
    homepage = "https://github.com/makeworld-the-better-one/amfora";
    license = licenses.gpl3;
  };
}
