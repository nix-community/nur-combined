(() => {
  if (window.location.pathname != '/') return;
  int = setInterval(() => {
    // Enables connected skins
    if (window.DEVHOOK_CONNECTED_SKIN) {
      // window.DEVHOOK_CONNECTED_SKIN();
      // note: yes this is absolutely horrifying, but it's an easy fix to a different skin being loaded.
      // the winter 2022 event introduced a new internal skin called `frosty2022`, which it loads by default.
      // `DEVHOOK_CONNECTED_SKIN()` just sets the skin back to `connected_test`. It's an extremely trivial function,
      // consisting of only two assignments, so this should have absolutely no noticeable performance impact.
      setInterval(() => window.DEVHOOK_CONNECTED_SKIN(), 1000);
      clearInterval(int);
    }
  }, 1000);
})();
