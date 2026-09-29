{
  lib,
  stdenv,
  fetchFromGitLab,
  perl,
  perlPackages,
  makeWrapper,
  dpkg,
  git-buildpackage,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dgit";
  version = "17.0";

  src = fetchFromGitLab {
    domain = "salsa.debian.org";
    owner = "dgit-team";
    repo = "dgit";
    tag = "debian/${finalAttrs.version}";
    hash = "sha256-uVbWHGziWENkMzVWdMH5pfTsiDxDRExD9L8w+LqkHjM=";
  };

  nativeBuildInputs = [
    perl
    makeWrapper
  ];

  buildInputs = [
    perl
  ];

  makeFlags = [ "prefix=$(out)" ];

  # Don't install the binaries used for uploads
  postInstall = ''
    rm $out/bin/{mini-git-tag-fsck,tag2upload-{fetch-inputs,obtain-origs}}
    wrapProgram $out/bin/dgit \
      --prefix PERL5LIB : "$out/share/perl5:${
        perlPackages.makePerlPath [
          dpkg
          perlPackages.LocaleGettext
          perlPackages.WWWCurl
          perlPackages.ListMoreUtils
          perlPackages.FilePath
          perlPackages.ExporterTiny
          perlPackages.TextGlob
          perlPackages.TextCSV
          perlPackages.JSON
          perlPackages.URI
          perlPackages.TextIconv
        ]
      }" \
      --prefix PATH : "$out/bin:${
        lib.makeBinPath [
          dpkg
          git-buildpackage
        ]
      }"
  '';

  meta = {
    description = "git integration with the Debian archive";
    homepage = "https://salsa.debian.org/dgit-team/dgit";
    changelog = "https://salsa.debian.org/debian/sbuild/-/blob/${finalAttrs.src.tag}/debian/changelog";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    badPlatforms = [ "aarch64-linux" ];
    mainProgram = "dgit";
  };
})
