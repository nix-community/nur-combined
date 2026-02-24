{
  pkgs,
}:

{
  mkGitRepository =
    src:
    pkgs.runCommandLocal "repository.git"
      {
        inherit src;
        nativeBuildInputs = [ pkgs.git ];
        env = {
          GIT_AUTHOR_NAME = src.meta.author or "root";
          GIT_AUTHOR_EMAIL = src.meta.email or "root@localhost";
          GIT_COMMITTER_NAME = src.meta.author or "root";
          GIT_COMMITTER_EMAIL = src.meta.email or "root@localhost";
          # date -d@100000000 -R
          GIT_AUTHOR_DATE = "Sat, 03 Mar 1973 09:46:40 +0000";
          GIT_COMMITTER_DATE = "Sat, 03 Mar 1973 09:46:40 +0000";
          # cleaner git repos without the hooks
          GIT_TEMPLATE_DIR = pkgs.emptyDirectory.outPath;
        };
      }
      ''
        mkdir build
        pushd build
        git -c init.defaultBranch=master init .
        if [[ -f $src ]] ; then
          filenamelocal=$(basename $src | sed 's/[a-z0-9A-Z]\+-\(.*\)/\1/g' )
          cp -v -- $src $filenamelocal
        else
          cp -rv -- $src/* .
        fi
        git add .
        git commit --allow-empty-message --message ""
        mv .git $out
        popd
      '';

  mkGitRepoFromBundleFile =
    { bundlefile }:
    pkgs.runCommandLocal "source"
      {
        nativeBuildInputs = [
          pkgs.git
        ];
        # to prevent junk
        env.GIT_TEMPLATE_DIR = pkgs.emptyDirectory.outPath;
      }
      ''
        git clone ${bundlefile} $out
      '';
}
