{
  lib,
  buildGoModule,
  fetchFromGitea,
  ghostscript,
  makeWrapper,
}:

buildGoModule rec {
  pname = "cpdf";
  version = "0.1.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "zzzsy";
    repo = "cpdf";
    rev = "ee5ea82";
    hash = "sha256-pvKRHfCNd509bWBWxquDoBa1ucOq88OkHX2e0/p7D/Y=";
  };

  vendorHash = "sha256-l6CMJGbx3Bdeuxb8x10Le9PLqY+xnV9yiKl0dFV+66o=";

  ldflags = [
    "-w -s"
    "-X=main.Version=${version}"
    "-X=main.Commit=${src.rev}"
    "-X=main.BuildSource=nix"
  ];

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/cpdf \
      --prefix PATH : ${lib.makeBinPath [ ghostscript ]}
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/zzzsy/cpdf";
    description = "A small tool using GhostScript ";
    license = licenses.bsd3;
    maintainers = with maintainers; [ zzzsy ];
    mainProgram = "cpdf";
  };
}
