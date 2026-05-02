{
  lib,
  fetchFromGitHub,
}:

{
  name = "nginx-cgi";
  src = fetchFromGitHub {
    owner = "pjincz";
    repo = "nginx-cgi";
    rev = "v0.15";
    hash = "sha256-HsMn2VdiClioJV19YF+lUHX4Tn/NNSml06YNbbEPdUY=";
  };
  meta = with lib; {
    description = "Nginx CGI module";
    homepage = "https://github.com/pjincz/nginx-cgi";
    license = with licenses; [ bsd2 ];
    maintainers = with maintainers; [ ];
  };
}
