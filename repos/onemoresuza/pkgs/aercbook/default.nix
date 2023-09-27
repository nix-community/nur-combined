{
  lib,
  stdenv,
  fetchFromSourcehut,
  zig_0_11,
}:
stdenv.mkDerivation rec {
  pname = "aercbook";
  version = "0.1.4";
  src = fetchFromSourcehut {
    domain = "sr.ht";
    owner = "~renerocksai";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Q+YST7K9Pjc04MqvB8W0TzUUE/AFIU72GBeZfVEn6mk=";
  };

  nativeBuildInputs = [
    zig_0_11.hook
  ];

  meta = with lib; {
    description = "A minimalistic address book for the aerc e-mail client";
    longDescription = ''
      A minimalistic address book for the aerc e-mail client. It enables fuzzy
      tab-completion of e-mail addresses in aerc.

      fuzzy-search in address book for tab-completion, with wildcard support
      add to address book from the command line
      parse e-mail headers and add To: and CC: addresses to address book
    '';
    homepage = "https://sr.ht/~renerocksai/aercbook/";
    license = licenses.mit;
    mainProgram = "aercbook";
  };
}
