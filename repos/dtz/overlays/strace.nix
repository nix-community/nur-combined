self: super: {
  strace = super.strace.overrideAttrs (o: rec {
    name = "strace-${version}";
    version = "2018-09-27";

    src = super.fetchgit {
      url = https://github.com/strace/strace;
      rev = "f5b9ee494540741b59453a61f06e19815bcb11bd";
      sha256 = "0j2kphnd7m2anfgkrd9kqwagv2jp1if7fcaxywjilnz6ad0lc8m5";
      leaveDotGit = true;
    };

    nativeBuildInputs = (o.nativeBuildInputs or [])
    ++ (with self; [
      git
      autoconf automake libtool
    ]);

    preConfigure = "./bootstrap";
  });
}
