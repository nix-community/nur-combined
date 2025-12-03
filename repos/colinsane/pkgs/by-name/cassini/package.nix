{
  lib,
  fetchFromGitHub,
  fetchFromGitea,
  fetchpatch,
  python3,
  stdenvNoCC,
}: stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cassini";
  version = "0-unstable-2024-03-30";

  # src = fetchFromGitHub {
  #   owner = "vvuk";
  #   repo = "cassini";
  #   rev = "052265f2a287b40e06971cfa3d66fc83bda19f93";
  #   hash = "sha256-lk4Y5aGSVHBY4Lju7Q9QDknSvo8PK6YdhQkmoIhFVec=";
  # };
  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "cassini";
    rev = "4c8fae92cac1f15101cfb96f71aaf8e491a4f392";
    hash = "sha256-fHhR4hiBowQzl2GW8z7ugYvYYyWYVc70pILwRzw+lPU=";
  };

  # patches = [
  #   # project has only requirements.txt,
  #   # i'm not sure how to _install_ it, except by switching it to setuptools
  #   (fetchpatch {
  #     name = "Update to Setuptools Python Packaging";
  #     url = "https://github.com/vvuk/cassini/pull/13.patch";
  #     hash = "sha256-XNK3Oxxu7Xm7rbr1cWgtXa/jNNk3T1Z5qXikuTSuL6U=";
  #   })
  # ];

  # postPatch = ''
  #   substituteInPlace setup.py \
  #     --replace-fail 'packages=find_packages()' 'packages=["cassini"]' \

  #   # --replace-fail 'entry_points=' '# entry_points=' \
  # '';

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/opt/cassini

    cp *.py $out/opt/cassini
  '';

  postFixup = ''
    wrapPythonProgramsIn "$out/opt/cassini" "$out $pythonPath"

    mkdir -p $out/bin
    ln -s $out/opt/cassini/cassini.py $out/bin/cassini
  '';

  nativeBuildInputs = [
    # python3.pkgs.hatch-fancy-pypi-readme
    # python3.pkgs.hatch-vcs
    # python3.pkgs.hatchling

    # python3.pkgs.poetry-core

    # python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    # python3.pkgs.setuptoolsBuildHook
    # python3.pkgs.wheel
    # python3.pkgs.eggUnpackHook
    # python3.pkgs.eggBuildHook
    # python3.pkgs.eggInstallHook
    python3.pkgs.wrapPython
    # python3.pkgs.pythonOutputDistHook
  ];

  propagatedBuildInputs = [
    python3.pkgs.alive-progress
    python3.pkgs.scapy
  ];
  nativeCheckInputs = [
    python3.pkgs.pythonImportsCheckHook
  ];

  pythonImportsCheck = [
    "cassini"
  ];

  # TODO: this isn't a "proper" Python package, because even though i've been writing Python for 15 years i still don't have a fucking clue how to navigate its packaging system.
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/vvuk/cassini";
    description = "ELEGOO 3D printer network protocol client";
    maintainers = with maintainers; [ colinsane ];
  };
})
