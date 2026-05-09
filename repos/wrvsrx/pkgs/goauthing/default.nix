{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "goauthing";
  version = "2.4.0";
  src = fetchFromGitHub {
    owner = "z4yx";
    repo = "GoAuthing";
    tag = "v${version}";
    fetchSubmodules = false;
    sha256 = "sha256-BeQXyahSTyaQ+2ai7oKVszTsvNsZuTeuXs95w4nlpvk=";
  };
  vendorHash = "sha256-Lwx3Z+BXFf2GWcJjTKEt4gZ7LO+UIbile7U7N/1+quU=";
  subPackages = [ "cli" ];
  postInstall = "mv $out/bin/cli $out/bin/auth-thu";
  meta = with lib; {
    description = "Authentication utility for srun4000 (auth.tsinghua.edu.cn / net.tsinghua.edu.cn / Tsinghua-IPv4)";
    homepage = "https://github.com/z4yx/GoAuthing";
    license = licenses.gpl3Only;
    mainProgram = "auth-thu";
  };
}
