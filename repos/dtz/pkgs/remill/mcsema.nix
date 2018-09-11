{ fetchFromGitHub }:

{
  version = "2018-09-10";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "855d65f4c361a2c5e55535b15bee09fda1e87984";
    sha256 = "0d0j94hzrj5gafbcpyw4d3k0i6lh9v371kmspdw4b5pkyhfj0z1i";
    name = "mcsema-source";
  };
}
