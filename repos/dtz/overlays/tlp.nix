self: super: {
##  tlp = super.tlp.overrideAttrs (o: rec {
##    name = "tlp-${version}";
##    version = "1.3.0";
##    #version = "2019-10-02";
##    src = super.fetchFromGitHub {
##      owner = "linrunner";
##      repo = "tlp";
###      rev = "eca65630eca23f55e03dd67c165157b17fce470a";
##      rev = version;
##      sha256 = "1bgx9psgx9izvhi0y76ayik6ymxsbj3rb9a0y4l1sxx1b4smixg8";
##    };
##  });
}
