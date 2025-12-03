{
  lib,
  fetchFromGitHub,
}:

{
  name = "nginx-cgi";
  src = fetchFromGitHub {
    owner = "pjincz";
    repo = "nginx-cgi";
    rev = "v0.13";
    hash = "sha256-rQBiB/N3rnOArP8tJu0wYMTHU31MpGdqeaUcSPKhJKs=";
  };
  meta = with lib; {
    description = "Nginx CGI module";
    homepage = "https://github.com/pjincz/nginx-cgi";
    license = with licenses; [ bsd2 ];
    maintainers = with maintainers; [ ];
  };
}
