# ladybird_patched

`ladybird` (the LibWeb browser) with built-in user-script support and the
**YT Mirror** feature ported from the Chrome extension:

<https://chromewebstore.google.com/detail/yt-mirror/nokjcgeafjfhlbclmmgfeiiebgjfollb>

## What the patch adds

Ladybird has no extension store, so `0001-yt-mirror-builtin-user-script.patch`
adds a small, generic user-script mechanism plus the actual feature:

- `Base/res/ladybird/user-scripts/yt-mirror.js` — the feature script, a port of
  the Chrome extension. It injects a "Mirror" button into the YouTube player
  (and Shorts) and toggles `transform: scaleX(-1)` on `.html5-video-container`
  to flip the video horizontally.
- `Services/WebContent/PageClient.{h,cpp}` — `maybe_inject_site_user_scripts()`
  runs once per top-level document after load; if the document is a YouTube
  page it queues a task that evaluates `yt-mirror.js` via `ClassicScript`. Both
  `page_did_finish_loading` and `page_did_completely_finish_loading` are hooked
  so late-finishing documents are covered too.
- `UI/cmake/ResourceFiles.cmake` — installs the user scripts to
  `${prefix}/share/Lagom/ladybird/user-scripts`, where the WebContent process
  loads them as `resource://ladybird/user-scripts/<name>`.

Adding more built-in scripts is a matter of dropping a file in
`Base/res/ladybird/user-scripts/`, listing it in `USER_SCRIPTS`, and extending
`is_youtube_document()`/`maybe_inject_site_user_scripts()` for the target site.
