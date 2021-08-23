;;; private/library/config.el -*- lexical-binding: t; -*-

(defconst sys/linuxp
  (eq system-type 'gnu/linux)
  "Are we running on a GNU/Linux system?")

(defconst sys/macp
  (eq system-type 'darwin)
  "Are we running on a Mac system?")

(defconst sys/mac-x-p
  (and (display-graphic-p) sys/macp)
  "Are we running under X on a Mac system?")

(defconst sys/mac-ns-p
  (eq window-system 'ns)
  "Are we running on a GNUstep or Macintosh Cocoa display?")

(defconst sys/mac-cocoa-p
  (featurep 'cocoa)
  "Are we running with Cocoa on a Mac system?")

(defconst sys/mac-port-p
  (eq window-system 'mac)
  "Are we running a macport build on a Mac system?")

(defconst sys/linux-x-p
  (and (display-graphic-p) sys/linuxp)
  "Are we running under X on a GNU/Linux system?")

(defconst sys/cygwinp
  (eq system-type 'cygwin)
  "Are we running on a Cygwin system?")

(defconst sys/rootp
  (string-equal "root" (getenv "USER"))
  "Are you using ROOT user?")

(defconst emacs/>=25p
  (>= emacs-major-version 25)
  "Emacs is 25 or above.")

(defconst emacs/>=26p
  (>= emacs-major-version 26)
  "Emacs is 26 or above.")

(defconst emacs/>=25.3p
  (or emacs/>=26p
      (and (= emacs-major-version 25)
           (>= emacs-minor-version 3)))
  "Emacs is 25.3 or above.")

(defconst emacs/>=25.2p
  (or emacs/>=26p
      (and (= emacs-major-version 25)
           (>= emacs-minor-version 2)))
  "Emacs is 25.2 or above.")

(defconst emacs/>=27p
  (>= emacs-major-version 27)
  "Emacs is 27 or above.")

(defconst emacs/>=28p
  (>= emacs-major-version 28)
  "Emacs is 28 or above.")


(with-no-warnings
  ;; Key Modifiers
  (cond
   (sys/mac-port-p
    ;; Compatible with Emacs Mac port
    (setq mac-option-modifier 'meta
          mac-command-modifier 'super)
    (bind-keys ([(super a)] . mark-whole-buffer)
               ([(super c)] . kill-ring-save)
               ([(super l)] . goto-line)
               ([(super q)] . save-buffers-kill-emacs)
               ([(super s)] . save-buffer)
               ([(super v)] . yank)
               ([(super w)] . delete-frame)
               ([(super z)] . undo))))

  ;; Optimization
  (unless sys/macp
    (setq command-line-ns-option-alist nil))
  (unless sys/linuxp
    (setq command-line-x-option-alist nil))

  ;; Increase how much is read from processes in a single chunk (default is 4kb)
  (setq read-process-output-max #x10000)  ; 64kb

  ;; Don't ping things that look like domain names.
  (setq ffap-machine-p-known 'reject)

  ;; Garbage Collector Magic Hack
  ;; (use-package! gcmh
  ;;   :diminish
  ;;   :init
  ;;   (setq gcmh-idle-delay 5
  ;;         gcmh-high-cons-threshold #x1000000) ; 16MB
  ;;   (gcmh-mode 1))
  )

;; Encoding
;; UTF-8 as the default coding system
(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))

;; Explicitly set the prefered coding systems to avoid annoying prompt
;; from emacs (especially on Microsoft Windows)
(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)

(set-language-environment 'utf-8)
(set-default-coding-systems 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-clipboard-coding-system 'utf-8)
(set-file-name-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(modify-coding-system-alist 'process "*" 'utf-8)

;; Environment
;; (when (or sys/mac-x-p sys/linux-x-p (daemonp))
;;   (use-package! exec-path-from-shell
;;     :init
;;     (setq exec-path-from-shell-variables '("PATH" "MANPATH"
;;                                            "GOPATH" "GO111MODULE" "GOPROXY" "GRADLE_HOME" "GROOVY_HOME" "JAVA_HOME" "MAVEN_HOME" "SBT_HOME" "SCALA_HOME" "WORKON_HOME" "PYENV_ROOT")
;;           exec-path-from-shell-arguments '("-l"))
;;     (exec-path-from-shell-initialize)))

;; Start server
(use-package! server
  :hook (after-init . server-mode))

;; History
(use-package! saveplace
  :hook (after-init . save-place-mode))

(use-package! recentf
   :bind (("C-x C-r" . recentf-open-files))
   :hook (after-init . recentf-mode)
   :init (setq recentf-max-saved-items 300
               recentf-exclude
               '("\\.?cache" ".cask" "url" "COMMIT_EDITMSG\\'" "bookmarks"
                 "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
                 "\\.?ido\\.last$" "\\.revive$" "/G?TAGS$" "/.elfeed/"
                 "^/tmp/" "^/var/folders/.+$" "^/ssh:" "/persp-confs/"
                 (lambda (file) (file-in-directory-p file package-user-dir))))
   :config
   (push (expand-file-name recentf-save-file) recentf-exclude)
   (add-to-list 'recentf-filename-handlers #'abbreviate-file-name))

(use-package! savehist
   :hook (after-init . savehist-mode)
   :init (setq enable-recursive-minibuffers t ; Allow commands in minibuffers
               history-length 1000
               savehist-additional-variables '(mark-ring
                                               global-mark-ring
                                               search-ring
                                               regexp-search-ring
                                               extended-command-history)
               savehist-autosave-interval 300))
(use-package! simple
              :hook ((after-init . size-indication-mode)
                     (text-mode . visual-line-mode)
                     ((prog-mode markdown-mode conf-mode) . enable-trailing-whitespace))
              :init
              (setq column-number-mode t
                    line-number-mode t
                    ;; kill-whole-line t               ; Kill line including '\n'
                    line-move-visual nil
                    track-eol t                     ; Keep cursor at end of lines. Require line-move-visual is nil.
                    set-mark-command-repeat-pop t)  ; Repeating C-SPC after popping mark pops it again

              ;; Visualize TAB, (HARD) SPACE, NEWLINE
              (setq-default show-trailing-whitespace nil) ; Don't show trailing whitespace by default
              (defun enable-trailing-whitespace ()
                "Show trailing spaces and delete on saving."
                (setq show-trailing-whitespace t)
                (add-hook 'before-save-hook #'delete-trailing-whitespace nil t)))

(use-package! time
  :unless (display-graphic-p)
  :hook (after-init . display-time-mode)
  :init (setq display-time-24hr-format t
              display-time-day-and-date t))

(when emacs/>=27p
  (use-package! so-long
    :hook (after-init . global-so-long-mode)
    :config (setq so-long-threshold 400)))

;; Misc
(fset 'yes-or-no-p 'y-or-n-p)
(setq-default major-mode 'text-mode
              fill-column 120
              tab-width 4
              indent-tabs-mode nil)     ; Permanently indent with spaces, never with TABs

(setq visible-bell t
      inhibit-compacting-font-caches t  ; Don’t compact font caches during GC.
      delete-by-moving-to-trash t       ; Deleting files go to OS's trash folder
      make-backup-files nil             ; Forbide to make backup files
      auto-save-default nil             ; Disable auto save

      uniquify-buffer-name-style 'post-forward-angle-brackets ; Show path if names are same
      adaptive-fill-regexp "[ t]+|[ t]*([0-9]+.|*+)[ t]*"
      adaptive-fill-first-line-regexp "^* *$"
      sentence-end "\\([。！？]\\|……\\|[.?!][]\"')}]*\\($\\|[ \t]\\)\\)[ \t\n]*"
      sentence-end-double-space nil)

;; Fullscreen
;; WORKAROUND: fix blank screen issue on macOS.
(defun fix-fullscreen-cocoa ()
  "Address blank screen issue with child-frame in fullscreen."
  (and sys/mac-cocoa-p
       emacs/>=26p
       (bound-and-true-p ns-use-native-fullscreen)
       (setq ns-use-native-fullscreen nil)))

(when (display-graphic-p)
  (add-hook 'window-setup-hook #'fix-fullscreen-cocoa)
  (bind-keys ("C-<f11>" . toggle-frame-fullscreen)
             ("C-s-f" . toggle-frame-fullscreen) ; Compatible with macOS
             ("S-s-<return>" . toggle-frame-fullscreen)
             ("M-S-<return>" . toggle-frame-fullscreen)))

(provide 'init-const)
