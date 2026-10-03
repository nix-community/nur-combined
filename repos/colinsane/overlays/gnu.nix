final: prev: {
  # 2026-10-02: fixes failing build
  see-cat = final.pkgsMusl.see-cat;

  # 2026-10-02: fixes conflict between glibc 2.44 and some pthread-related headers tor vendors.
  tor-browser-from-src = prev.pkgsMusl.tor-browser-from-src;
}
