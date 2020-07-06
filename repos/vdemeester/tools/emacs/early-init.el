;; Early initialization
;; :PROPERTIES:
;; :header-args: :tangle ~/src/home/tools/emacs/early-init.el
;; :header-args+: :comments org
;; :CUSTOM_ID: h:ec67a339-378c-4c2c-93f8-9ce62308cccb
;; :END:
;; 
;; Starting with Emacs 27, an =early-init.el= file can be used to do early configuration
;; and optimization.
;; 
;; #+begin_quote
;; Emacs can now be configured using an early init file. The file is called ~early-init.el~,
;; in ~user-emacs-directory~. It is loaded very early in the startup process: before
;; graphical elements such as the tool bar are initialized, and before the package manager is
;; initialized. The primary purpose is to allow customizing how the package system is
;; initialized given that initialization now happens before loading the regular init file
;; (see below).
;; 
;; We recommend against putting any customizations in this file that don't need to be set up
;; before initializing installed add-on packages, because the early init file is read too
;; early into the startup process, and some important parts of the Emacs session, such as
;; 'window-system' and other GUI features, are not yet set up, which could make some
;; customization fail to work.
;; #+end_quote
;; 
;; We can use this to our advantage and optimize the initial loading of emacs.
;; 
;; - Before Emacs 27, the init file was responsible for initializing the package manager by
;;   calling `package-initialize'.  Emacs 27 changed the default behavior: It now calls
;;   `package-initialize' before loading the init file.


(setq package-enable-at-startup nil)



;; - Let's inhibit resizing the frame at early stage.


(setq frame-inhibit-implied-resize t)



;; - I never use the /menu-bar/, or the /tool-bar/ or even the /scroll-bar/, so we can safely
;;   disable those very very early.


(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(horizontal-scroll-bar-mode -1)



;; - Finally we can try to avoid garbage collection at startup. The garbage collector can
;;   easily double startup time, so we suppress it at startup by turning up ~gc-cons-threshold~
;;   (and perhaps ~gc-cons-percentage~) temporarily.


(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)



;; - Another small optimization concerns on =file-name-handler-alist= : on every .el and .elc
;;   file loaded during start up, it has to runs those regexps against the filename ; setting
;;   it to ~nil~ and after initialization finished put the value back make the initialization
;;   process quicker.


(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)



;;   However, it is important to reset it eventually. Not doing so will cause garbage
;;   collection freezes during long-term interactive use. Conversely, a ~gc-cons-threshold~
;;   that is too small will cause stuttering. This will be done at the end.
;; 
;; - It's also possible to put the theme *and* the font in =early-init.el= to speed the
;;   start.


(defvar contrib/after-load-theme-hook nil
  "Hook run after a color theme is loaded using `load-theme'.")

(defun contrib/run-after-load-theme-hook (&rest _)
  "Run `contrib/after-load-theme-hook'."
  (run-hooks 'contrib/after-load-theme-hook))

(advice-add #'load-theme :after #'contrib/run-after-load-theme-hook)
(require 'modus-operandi-theme)

(defun sbr/modus-operandi ()
  "Enable some Modus Operandi variables and load the theme.
This is used internally by `sbr/modus-themes-toggle'."
  (setq modus-operandi-theme-slanted-constructs t
        modus-operandi-theme-bold-constructs t
        modus-operandi-theme-visible-fringes nil
        modus-operandi-theme-3d-modeline t
        modus-operandi-theme-subtle-diffs t
        modus-operandi-theme-distinct-org-blocks nil
        modus-operandi-theme-proportional-fonts nil
        modus-operandi-theme-rainbow-headings t
        modus-operandi-theme-section-headings nil
        modus-operandi-theme-scale-headings nil
        modus-operandi-theme-scale-1 1.05
        modus-operandi-theme-scale-2 1.1
        modus-operandi-theme-scale-3 1.15
        modus-operandi-theme-scale-4 1.2)
  (load-theme 'modus-operandi t))

(defun sbr/modus-operandi-custom ()
  "Customize modus-operandi theme"
  (if (member 'modus-operandi custom-enabled-themes)
      (modus-operandi-theme-with-color-variables ; this macro allows us to access the colour palette
        (custom-theme-set-faces
         'modus-operandi
         `(whitespace-tab ((,class (:background "#ffffff" :foreground "#cccccc"))))
         `(whitespace-space ((,class (:background "#ffffff" :foreground "#cccccc"))))
         `(whitespace-hspace ((,class (:background "#ffffff" :foreground "#cccccc"))))
         `(whitespace-newline ((,class (:background "#ffffff" :foreground "#cccccc"))))
         `(whitespace-indentation ((,class (:background "#ffffff" :foreground "#cccccc"))))
         ))))

(add-hook 'contrib/after-load-theme-hook 'sbr/modus-operandi-custom)
(sbr/modus-operandi)

(defconst font-height 130
  "Default font-height to use.")
;; Middle/Near East: שלום, السّلام عليكم
(when (member "Noto Sans Arabic" (font-family-list))
  (set-fontset-font t 'arabic "Noto Sans Arabic"))
(when (member "Noto Sans Hebrew" (font-family-list))
  (set-fontset-font t 'arabic "Noto Sans Hebrew"))
;; Africa: ሠላም
(when (member "Noto Sans Ethiopic" (font-family-list))
  (set-fontset-font t 'ethiopic "Noto Sans Ethiopic"))

;; Default font is Ubuntu Mono (and Ubuntu Sans for variable-pitch)
;; If Ubuntu Mono or Ubuntu Sans are not available, use the default Emacs face
(when (member "Ubuntu Mono" (font-family-list))
  (set-face-attribute 'default nil
                      :family "Ubuntu Mono"
                      :height font-height)
  (set-face-attribute 'fixed-pitch nil
                      :family "Ubuntu Mono"
                      :height font-height))
(when (member "Ubuntu Sans" (font-family-list))
  (set-face-attribute 'variable-pitch nil
                      :family "Ubuntu Sans"
                      :height font-height
                      :weight 'regular))

;; Ignore X resources; its settings would be redundant with the other settings
;; in this file and can conflict with later config (particularly where the
;; cursor color is concerned).
(advice-add #'x-apply-session-resources :override #'ignore)



;; - Reseting garbage collection and file-name-handler values.


(add-hook 'after-init-hook
          `(lambda ()
             (setq gc-cons-threshold 67108864 ; 64mb
                   gc-cons-percentage 0.1
                   file-name-handler-alist file-name-handler-alist-original)
             (garbage-collect)) t)
