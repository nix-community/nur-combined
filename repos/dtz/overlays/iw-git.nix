# hopefully short-lived, don't rely on this for anything other than curiosity :)
self: super: {
  iw-git = super.iw.overrideAttrs (o: rec {
    pname = "iw";
    version = "2020-03-04";

    src = super.fetchgit {
      url = https://git.kernel.org/pub/scm/linux/kernel/git/jberg/iw.git;
      rev = "08d7c407a5825f038b33374bfe30282445a4a76e";
      sha256 = "106iklwwpicl0gpfsby5jv5b7zbgjzvjrpsya6i3zk563zs3gqy7";
    };
  });
}
