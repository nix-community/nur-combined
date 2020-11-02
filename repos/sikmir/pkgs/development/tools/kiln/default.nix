{ lib, buildGoModule, fetchgit, sources }:

buildGoModule {
  pname = "kiln";
  version = "unstable-2020-11-02";

  src = fetchgit {
    url = "https://git.sr.ht/~adnano/kiln";
    rev = "fbe8122ebde2043de743d189402fa717fbfe0a90";
    sha256 = "121i7fqds8q15bwyld76p0n7rlpspj8kqvfd8pb62hi7897qm4zy";
  };

  vendorSha256 = "01axixmq1w9k3fh63105z4pxcxjan7l031yj62a9lz4cjlax743i";

  meta = with lib; {
    description = "A simple static site generator for Gemini";
    homepage = "https://git.sr.ht/~adnano/kiln";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
