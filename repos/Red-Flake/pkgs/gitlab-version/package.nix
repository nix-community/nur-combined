{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  nmap,
  makeWrapper,
  nseRev ? "0f34f9462e4a47047a9e61527257af18b782e476",
  nseHash ? "sha256-zRVRFrp5wqXdkbqRm1/0uCbyAmwHg7e7ByFj/DurUtQ=",
}:

let
  nse-data = fetchFromGitHub {
    owner = "righel";
    repo = "gitlab-version-nse";
    rev = nseRev;
    hash = nseHash;
  };
in
stdenv.mkDerivation {
  pname = "gitlab-version";
  version = "0-unstable-2026-03-25";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python3 ];

  dontBuild = true;

  installPhase = ''
    # Install the NSE data files
    mkdir -p $out/share/gitlab-version
    cp ${nse-data}/gitlab_version.nse $out/share/gitlab-version/
    cp ${nse-data}/gitlab_hashes.json $out/share/gitlab-version/

    # Install the Python script
    mkdir -p $out/bin
    cp gitlab_version.py $out/bin/gitlab_version
    chmod +x $out/bin/gitlab_version

    # Wrap with nmap in PATH and NSE dir set
    wrapProgram $out/bin/gitlab_version \
      --set GITLAB_VERSION_NSE_DIR "$out/share/gitlab-version" \
      --prefix PATH : ${lib.makeBinPath [ nmap ]}
  '';

  meta = with lib; {
    description = "Detect GitLab version and associated CVEs via nmap NSE script";
    homepage = "https://github.com/righel/gitlab-version-nse";
    license = licenses.asl20;
    mainProgram = "gitlab_version";
    platforms = platforms.linux;
  };
}
