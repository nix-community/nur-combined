#!@shell@
set -eu

profile="${XDG_CONFIG_HOME:-$HOME/.config}/idemacs"
mkdir -p "$profile/lisp"

# A stable loader lets upgrades pick up the new configuration while preserving
# the profile's custom.el, lisp/idemacs-user.lisp and session data.
export IDEMACS_INIT="@out@/share/idemacs/init.el"
if [[ ! -e "$profile/init.el" && ! -L "$profile/init.el" ]]; then
  (
    set -o noclobber
    cat > "$profile/init.el" <<'ELISP'
;; -*- lexical-binding: t -*-
(load (getenv "IDEMACS_INIT") nil t)
ELISP
  ) || [[ -f "$profile/init.el" ]]
fi

exec @emacs@ --init-directory="$profile" "$@"
