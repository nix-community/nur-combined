{ fetchzip }:

fetchzip {
  name = "hyperspec-7.0";
  urls = [
    "http://ftp.lispworks.com/pub/software_tools/reference/HyperSpec-7-0.tar.gz"
    "https://archive.org/download/common-lisp-hyperspec/HyperSpec-7-0.tar.gz"
  ];
  stripRoot = false;
  sha256 = "1zsi35245m5sfb862ibzy0pzlph48wvlggnqanymhgqkpa1v20ak";
  meta = {
    description = "The Common Lisp HyperSpec";
    homepage = "http://www.lispworks.com/documentation/HyperSpec/Front/index.htm";
  };
}
