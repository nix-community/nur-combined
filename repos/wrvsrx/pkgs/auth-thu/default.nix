{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "auth-thu";
  version = "2.3.4";
  src = fetchFromGitHub {
    owner = "z4yx";
    repo = "GoAuthing";
    tag = "v${version}";
    fetchSubmodules = false;
    sha256 = "sha256-BUvbUvkowbzS+m8CFtG1oimD/DmYUKTrLGfP2a2JA3U=";
  };
  vendorHash = "sha256-FRLpeOYOTSnq66qjljfomdSSHZhIxA0n3EcIqcoxn4c=";
  subPackages = [ "cli" ];
  postInstall = "mv $out/bin/cli $out/bin/$pname";
  meta = with lib; {
    description = "Authentication utility for srun4000 (auth.tsinghua.edu.cn / net.tsinghua.edu.cn / Tsinghua-IPv4)";
    homepage = "https://github.com/z4yx/GoAuthing";
    license = licenses.gpl3Only;
  };
}
