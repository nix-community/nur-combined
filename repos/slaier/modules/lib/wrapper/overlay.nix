final: prev:
{
  makeNoProxyWrapper = pkg: final.symlinkJoin {
    name = final.lib.getName pkg;
    paths = [ pkg ];
    buildInputs = [ final.makeWrapper ];
    postBuild = ''
      for program in $out/bin/*; do
        wrapProgram $program  \
          --unset all_proxy   \
          --unset https_proxy \
          --unset http_proxy  \
          --unset ftp_proxy   \
          --unset rsync_proxy \
          --unset no_proxy    \
          --unset RES_OPTIONS
      done
    '';
  };
}
