;; From http://www.howardism.org/Technical/Emacs/focused-work.html
;; Write something a bit similar, but better ?

(defvar vde/focus-timer nil "A timer reference for the vde/focus functions")

(defun vde/focus-countdown-timer (minutes fun)
  (let ((the-future (* minutes 60)))
    (run-at-time the-future nil fun)))

(defun vde/focus-begin ()
  "Start a concerted, focused effort, ala Pomodoro Technique.
We first clock into the current org-mode header (or last one),
start some music to indicate we are working, and set a timer.

Call `ha-focus-break' when finished."
  (interactive)
  (vde/focus-countdown-timer 25 'vde/focus-break)
  (vde/focus--command "playerctl play-pause")
  (vde/focus--command "notify-send 'Let's focus.'")
  (vde/focus--command "swaync-client -d")
  (if (eq major-mode 'org-mode)
      (org-clock-in)
    (org-clock-in-last)))

(defun vde/focus-break ()
  "Stop the focused time by stopping the music.
This also starts another break timer, that calls
`ha-focus-break-over' when finished."
  (interactive)
  (vde/focus-countdown-timer 5 'vde/focus-break-over)
  (vde/focus--command "swaync-client -d")
  (vde/focus--command "notify-send 'Let's take a break.'")
  (vde/focus--command "playerctl play-pause")
  (org-clock-out)
  (message "Time to take a break."))

(defun vde/focus-break-over ()
  "Message me to know that the break time is over. Notice that
this doesn't start anything automatically, as I may have simply
wandered off."
  (vde/focus--command "notify-send 'Break is over.'"))

(defun vde/focus--command (command)
  "Runs COMMAND by passing to the `command' command asynchronously."
  (async-start-process "focus-os" "zsh" 'vde/focus--command-callback "-c" command))

(defun vde/focus--command-callback (proc)
  "Asynchronously called when the `osascript' process finishes."
  (message "Finished calling command."))
