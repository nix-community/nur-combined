{ fetchFromGitHub }:

{
  version = "2019-03-09";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "91f6f26399d95db3796eda73df654571b86b0f2d";
    sha256 = "0ykfr4k6zf07p0v458q6qzf3njk3afh1wg5zn7saq558mh2laly7";
    name = "mcsema-source";
  };
}
