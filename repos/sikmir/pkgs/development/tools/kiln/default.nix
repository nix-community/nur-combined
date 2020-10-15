{ lib, buildGoModule, fetchgit, sources }:

buildGoModule {
  pname = "shavit";
  version = "unstable-2020-10-14";

  src = fetchgit {
    url = "https://git.sr.ht/~adnano/kiln";
    rev = "fa7c320822e1a0abb86100ad47d067538b6b4f34";
    sha256 = "0sd7plm820z3dwvfsr2cs4rq5kkqf0ykg2gpsrwqr9604l41sklg";
  };

  vendorSha256 = "0misd11hb9qrd8q668ms12lhk9ijx7nnjxy7qyr9lydnv8v8hz6i";

  meta = with lib; {
    description = "A simple static site generator for Gemini";
    homepage = "https://git.sr.ht/~adnano/kiln";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
