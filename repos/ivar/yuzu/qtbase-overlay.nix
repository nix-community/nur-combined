self: super: {
  # See https://codereview.qt-project.org/c/qt/qtbase/+/339323, this is required for building yuzu with gcc11
  qtbase = super.qtbase.overrideAttrs (attrs: {
    patches = attrs.patches or [] ++ [ ./fix-compilation.patch ];
  });
}
