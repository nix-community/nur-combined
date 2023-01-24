{
  stdenv,
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "speedtest-go";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "showwin";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-JkOYD8WAV/gKKFfv86IeFXK7uUdNphmqyytvcVLohJE=";
  };
  
  vendorHash = "sha256-Q9wICMzYkwcagkqcwluOokhMs9JPQ0EfG578RzWcamo=";
  
  doCheck = false;

  meta = with lib; {
    description = "CLI and Go API to Test Internet Speed using speedtest.net. ";
    homepage = "https://github.com/showwin/${pname}";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
