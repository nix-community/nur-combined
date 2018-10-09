self: super:
{
    compton-git = super.compton-git.overrideAttrs (o: rec {
      name = "compton-git-${version}";
      version = "2018-10-03";

      src = super.fetchFromGitHub {
        owner  = "yshui";
        repo   = "compton";
        rev    = "7b755a3cf01131b138282de71e5b569257565142";
        sha256 = "0gm6ga1am5cqd6c7zmjxh3jlvd967ypi0w8mn1hg23mxldlmn65g";
      };

      COMPTON_VERSION = "git-${version}-${src.rev}";

      # Default:
      #buildInputs = [
      #  dbus libX11 libXcomposite libXdamage libXrender libXrandr libXext
      #  libXinerama libdrm pcre libxml2 libxslt libconfig libGL
      #];

      buildInputs = with self; with xorg; [
        dbus libX11 libXcomposite libXext
        libXinerama libdrm pcre libxml2 libxslt libconfig libGL
        # Removed:
        # libXdamage libXrender libXrandr

        # New:
        libxcb xcbutilrenderutil xcbutilimage
        pixman libev
      ];

    });
    compton = self.compton-git;
}
