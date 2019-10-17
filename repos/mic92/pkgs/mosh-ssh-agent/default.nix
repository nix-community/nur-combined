{ stdenv, mosh, fetchFromGitHub }:

mosh.overrideAttrs (old: {
  name = "mosh-ssh-agent-2019-06-13";
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "mosh";
    rev = "a91d93275fd28b5b52c645fffe06ce369a9a27ab";
    sha256 = "0w7jxdsyxgnf5h09rm8mfgm5z1qc1sqwvgzvrwzb04yshxpsg0zd";
  };

  patches = [ ./ssh_path.patch ];

  meta = with stdenv.lib; {
    description = "Mosh fork with ssh-agent support";
    homepage = https://github.com/Mic92/mosh;
    license = stdenv.lib.licenses.gpl3Plus;
    platforms = stdenv.lib.platforms.unix;
  };
})
