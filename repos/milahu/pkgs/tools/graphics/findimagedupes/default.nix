# based on https://github.com/NixOS/nixpkgs/commit/f93ea48c582b4608647f4decfc3e2cb4bdf2966f

{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  makeWrapper,
  perl,
  perlPackages,
  installShellFiles,
}:

stdenv.mkDerivation rec {
  pname = "findimagedupes";
  version = "2.20.1";

  src = fetchFromGitHub {
    # https://github.com/jhnc/findimagedupes
    owner = "jhnc";
    repo = "findimagedupes";
    tag = version;
    hash = "sha256-LJbZGuBVksfS7nVxgrMLSeygWuy9oDmw/pD8wAyr3f0=";
  };

  nativeBuildInputs = [ makeWrapper installShellFiles ];

  buildInputs = [ perl ] ++ (with perlPackages; [
    DBFile
    FileMimeInfo
    FileBaseDir
    #GraphicsMagick
    ImageMagick
    Inline
    InlineC
    ParseRecDescent
  ]);

  # compiled files (findimagedupes.so etc) are written to $DIRECTORY/lib/auto/findimagedupes
  # replace GraphicsMagick with ImageMagick, because perl bindings are not yet available
  postPatch = ''
    substituteInPlace findimagedupes \
      --replace "DIRECTORY => '/usr/local/lib/findimagedupes';" "DIRECTORY => '$out';" \
      --replace "Graphics::Magick" "Image::Magick" \
      --replace "my \$Id = '""';" "my \$Id = '${version}';"
  '';

  # with DIRECTORY = "/tmp":
  # $ ./result/bin/findimagedupes
  # /bin/sh: line 1: cc: command not found
  # $ strace ./result/bin/findimagedupes 2>&1 | grep findimagedupes
  # newfstatat(AT_FDCWD, "/tmp/lib/auto/findimagedupes/findimagedupes.inl", {st_mode=S_IFREG|0644, st_size=585, ...}, 0) = 0
  # newfstatat(AT_FDCWD, "/tmp/lib/auto/findimagedupes/findimagedupes.so", {st_mode=S_IFREG|0555, st_size=16400, ...}, 0) = 0
  buildPhase = "
    runHook preBuild
    # fix: Invalid value '$out' for config option DIRECTORY
    mkdir $out
    # build findimagedupes.so
    # compile inline C code (perl Inline::C) on the first run
    # fix: Can't open $out/config-x86_64-linux-thread-multi-5.040000 for output. Read-only file system
    ${perl}/bin/perl findimagedupes
    # build manpage
    ${perl}/bin/pod2man findimagedupes > findimagedupes.1
    runHook postBuild
  ";

  installPhase = ''
    runHook preInstall
    install -D -m 755 findimagedupes $out/bin/findimagedupes
    installManPage findimagedupes.1
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/findimagedupes" \
      --prefix PERL5LIB : "${with perlPackages; makePerlPath [
        DBFile
        FileMimeInfo
        FileBaseDir
        #GraphicsMagick
        ImageMagick
        Inline
        InlineC
        ParseRecDescent
      ]}"
  '';

  meta = with lib; {
    homepage = "http://www.jhnc.org/findimagedupes/";
    description = "Finds visually similar or duplicate images";
    license = licenses.gpl3;
    # maintainers = with maintainers; [ stunkymonkey ];
    maintainers = with maintainers; [ ];
  };
}
