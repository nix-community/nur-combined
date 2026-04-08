{
  lib,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "gitlab-userenum";
  version = "0.1.0";

  src = ./.;
  format = "other";

  propagatedBuildInputs = with python3Packages; [
    requests
  ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp gitlab_userenum.py $out/bin/gitlab_userenum
    chmod +x $out/bin/gitlab_userenum
  '';

  meta = with lib; {
    description = "Enumerate valid usernames on a GitLab instance";
    license = licenses.mit;
    mainProgram = "gitlab_userenum";
    platforms = platforms.linux;
  };
}
