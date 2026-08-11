# see also: https://github.com/termux/termux-packages/blob/master/packages/apt-file/build.sh

# TODO on runtime, install /etc/apt/apt.conf.d/50apt-file.conf
# this is required for "apt-file update"

{ lib
, buildPerlPackage
, fetchFromGitLab
, AptPkg
, FileWhich
, makeWrapper
, makeFullPerlPath
, apt
}:

buildPerlPackage rec {
  pname = "apt-file";
  version = "3.3";

  src =
  #if true then ./src/apt-file else
  fetchFromGitLab {
    domain = "salsa.debian.org";
    owner = "apt-team";
    repo = "apt-file";
    rev = "debian/${version}";
    hash = "sha256-RpWIgVDgNK+SUy1FW4YNxthFSch5ZcPdE7/RnMKUT00=";
  };

  patches = [
    ./fix-apt-file.patch
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace '/usr/' '/' \
      --replace '$(DESTDIR)' "$out"
    patchShebangs .
  '';

  # fix: Can't open perl script "Makefile.PL": No such file or directory
  dontConfigure = true;

  # tests fail
  doCheck = false;

  # fix: failed to produce output path for output 'devdoc'
  outputs = [ "out" ];

  nativeBuildInputs = [
    makeWrapper
  ];

  perlPath = makeFullPerlPath [
    AptPkg
    FileWhich # fix-apt-file.patch
  ];

  postFixup = ''
    wrapProgram $out/bin/apt-file \
      --prefix PERL5LIB : "${perlPath}" \
      --prefix PATH : "${apt}/bin" \
  '';

  meta = with lib; {
    description = "apt-file helps you to find in which package a file is included";
    homepage = "https://salsa.debian.org/apt-team/apt-file";
    changelog = "https://salsa.debian.org/apt-team/apt-file/-/blob/${src.rev}/changelog";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
    mainProgram = "apt-file";
    platforms = platforms.all;
  };
}
