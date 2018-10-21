{ fetchFromGitHub }:

{
  version = "2018-10-21";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "2bc603b2d24ebf60768c8ebe2cf715b79f8a28b1";
    sha256 = "1s8xzqknwcavfylkj75r1vl3kxj7xw57bjk9hz1b7kvf17wvr5qp";
    name = "mcsema-source";
  };
}
