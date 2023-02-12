{
  stdenv,
  vim, 
  fetchFromGitHub, 
  acl,
  gtk3,
  libXt,
  wrapGAppsHook,
  glib,
  gdk-pixbuf,
  librsvg,
}:

vim.overrideAttrs (
  oldAttrs: rec{
    version = "9.0.1211";
    src = fetchFromGitHub {
      owner = "lilydjwg";
      repo = "vim";
      rev = "36328ba36582d4a212baa067c2f6582c705c2f3c";
      hash = "sha256-kCusoFd4cjUZd455u8Sj8GYZ6MTaYAShrc18cntJIN0=";
    };
    configureFlags = oldAttrs.configureFlags ++ [
      "--enable-gui=gtk3"
      "--with-compiledby='wsdjeg'"
    ];
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ wrapGAppsHook glib gdk-pixbuf ];
    buildInputs = oldAttrs.buildInputs ++ [ 
      acl
      gtk3
      libXt 
      glib
      librsvg
    ];
    postInstall = oldAttrs.postInstall + ''
      install -Dm755 $src/runtime/gvim.desktop $out/share/applications/gvim.desktop
    '';
  }
)
