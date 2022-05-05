{ fetchzip }:

fetchzip {
  name = "hyperspec-7.0";
  urls = [
    "http://ftp.lispworks.com/pub/software_tools/reference/HyperSpec-7-0.tar.gz"
    "https://archive.org/download/common-lisp-hyperspec/HyperSpec-7-0.tar.gz"
  ];
  downloadToTemp = true;
  sha256 = "sha256-m0pC2TrYAcL4Mn39B+D5Hn9VSXgu5NtQ6+WUGEuE8/M=";

  postFetch = ''
    mkdir -p $out/share/
    tar -C $out/share -xf $downloadedFile
  '';

  meta = {
    description = "The Common Lisp HyperSpec";
    homepage = "http://www.lispworks.com/documentation/HyperSpec/Front/index.htm";
  };
}
