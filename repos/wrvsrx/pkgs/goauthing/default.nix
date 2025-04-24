{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "goauthing";
  version = "2.3.5";
  src = fetchFromGitHub {
    owner = "z4yx";
    repo = "GoAuthing";
    tag = "v${version}";
    fetchSubmodules = false;
    sha256 = "sha256-pZD54SoumOoSOE+r2Llgw71h8wkJ15pqkPX/LRS2R2Y=";
  };
  vendorHash = "sha256-FRLpeOYOTSnq66qjljfomdSSHZhIxA0n3EcIqcoxn4c=";
  subPackages = [ "cli" ];
  postInstall = "mv $out/bin/cli $out/bin/auth-thu";
  meta = with lib; {
    description = "Authentication utility for srun4000 (auth.tsinghua.edu.cn / net.tsinghua.edu.cn / Tsinghua-IPv4)";
    homepage = "https://github.com/z4yx/GoAuthing";
    license = licenses.gpl3Only;
  };
}
