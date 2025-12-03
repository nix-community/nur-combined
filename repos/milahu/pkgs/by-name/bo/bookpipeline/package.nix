{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  xorg,
  libGL,
}:

buildGoModule rec {
  pname = "bookpipeline";
  version = "1.3.1-711f80e";

  src = fetchFromGitHub {
    owner = "rescribe";
    repo = "bookpipeline";
    rev = "711f80eec5d970b377a1c1e15f6914bbd152a11a";
    hash = "sha256-tu5Nhhbzwtwo+u7dTQzHqWEccjGYXmIK6tNsLYvgzBE=";
  };

  vendorHash = "sha256-mc7vNjYZnkLkr06LzsdyxALNE8vxOtiEagcuhws62EE=";

  ldflags = [ "-s" "-w" ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    xorg.libX11
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXinerama
    xorg.libXi
    xorg.libXxf86vm
    libGL
  ];

  # tests fail
  # https://github.com/rescribe/bookpipeline/issues/10
  doCheck = false;

  meta = {
    description = "Tools to process books in a cloud based pipeline system (addtoqueue, bookpipeline, booktopipeline, confgraph, getallhocrs, getandpurgequeue, getbests, getpipelinebook, getsamplepages, getstats, logwholequeue, lspipeline, lspipeline-ng, mkpipeline, pagegraph, pdfbook, postprocess-bythresh, rescribe, rmbook, spotme, trimqueue)";
    homepage = "https://github.com/rescribe/bookpipeline";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "bookpipeline";
  };
}
