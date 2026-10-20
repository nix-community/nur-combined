{
  default =
    final: _prev:
    import ../pkgs { pkgs = final; }
    // {
      # Compatibility alias; CI and update automation use the canonical name.
      rimsort = final.rimsort-appimage;
    };
}
