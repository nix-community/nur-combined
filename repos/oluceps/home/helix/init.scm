(require "helix-fcitx-focus/cogs/fcitx-focus.scm")
(require "helix-file-watcher/file-watcher.scm")
(require "oil/oil.scm")
(require "helix/keymaps.scm")

(spawn-watcher)

(keymap (global)
  (normal
    (space (e ":oil"))))

(keymap (buffer "*oil*" (inherit-from (deep-copy-global-keybindings)))
  (with-map
    (keymap
      (normal
        (ret ":oil-enter")
        ("-" ":oil-up")
        (space
          (s ":oil-save")
          (r ":oil-refresh")
          (q ":oil-close")
          (h ":oil-toggle-hidden"))))))
