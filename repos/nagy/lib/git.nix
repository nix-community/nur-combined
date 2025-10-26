{ pkgs, ... }:

{
  mkGitRepository =
    src:
    pkgs.runCommandLocal "repository.git"
      {
        inherit src;
        nativeBuildInputs = [ pkgs.git ];
        GIT_AUTHOR_NAME = src.meta.author or "root";
        GIT_AUTHOR_EMAIL = src.meta.email or "root@localhost";
        GIT_COMMITTER_NAME = src.meta.author or "root";
        GIT_COMMITTER_EMAIL = src.meta.email or "root@localhost";
        # date -d@100000000 -R
        GIT_AUTHOR_DATE = "Sat, 03 Mar 1973 09:46:40 +0000";
        GIT_COMMITTER_DATE = "Sat, 03 Mar 1973 09:46:40 +0000";
        # cleaner git repos without the hooks
        GIT_TEMPLATE_DIR = pkgs.emptyDirectory.outPath;
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

  mkGitMirror =
    url:
    pkgs.runCommandLocal "git-mirror"
      {
        nativeBuildInputs = with pkgs; [
          git
          cacert
        ];
        inherit url;
        # to prevent junk
        GIT_TEMPLATE_DIR = pkgs.emptyDirectory.outPath;
      }
      ''
        mkdir $out
        cd $out
        git clone --mirror $url .
      '';

  mkGitCloneSingleBranch =
    {
      url,
      rev,
      outputHash,
    }@args:
    pkgs.runCommandLocal "${baseNameOf url}-clone"
      (
        {
          nativeBuildInputs = with pkgs; [
            git
            cacert
          ];
          # to prevent junk
          GIT_TEMPLATE_DIR = pkgs.emptyDirectory.outPath;
          outputHashMode = "recursive";
          outputHashAlgo = "sha256";
        }
        // args
      )
      ''
        git init --bare $out
        git -C $out fetch $url $rev
        git -C $out update-ref HEAD $(git -C $out rev-list -n 1 FETCH_HEAD)
      '';

  mkGitRepoFromBundleFile =
    {
      bundlefile,
      git ? pkgs.git,
    }:
    pkgs.runCommandLocal "source" { nativeBuildInputs = [ git ]; } ''
      git clone ${bundlefile} $out
      cd $out
      mkdir -p .git/info && echo '*.json -filter' > .git/info/attributes
    '';
}
