{ stdenv, mosh, fetchFromGitHub, fetchpatch }:

mosh.overrideAttrs (old: {
  name = "mosh-ssh-agent-2019-06-13";
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "mosh";
    rev = "a91d93275fd28b5b52c645fffe06ce369a9a27ab";
    sha256 = "0i1r1yi4cdqmchnjnvfv7d50dqv67hky4476q07vhzp4a468zm6d";
  };

  patches = [
    ./ssh_path.patch
    # support for osc-52
    # https://github.com/mobile-shell/mosh/pull/1054
    (fetchpatch {
      url = "https://github.com/mobile-shell/mosh/commit/9c8f95627f374cd9f4bca7267084e9849bd673f0.patch";
      sha256 = "0gjf7sw5bnfhw81yqbvixgr2fhzzdh4lgs835vvmh0p781ih0riz";
    })
  ];

  meta = with stdenv.lib; {
    description = "Mosh fork with ssh-agent support";
    homepage = https://github.com/Mic92/mosh;
    license = stdenv.lib.licenses.gpl3Plus;
    platforms = stdenv.lib.platforms.unix;
  };
})
