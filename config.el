;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Stamno stomp"
      user-mail-address "stamno@stamno.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font "dina-font")
(setq doom-font "Dina:pixelsize=20:antialias=off")
;;(setq doom-font "Nia Font:pixelsize=15:foundry=CLGR:weight=regular:slant=normal:width=normal:scalable=true")
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;(setq doom-theme 'doom-gruvbox)
;;(setq doom-theme 'doom-earl-grey)
;;(setq doom-theme 'doom-everblush)
;;(setq doom-theme 'doom-zenburn)
(setq doom-theme 'doom-sourcerer)
;;(setq doom-theme   'doom-gruvbox-light)
(setq shell-file-name (executable-find "bash"))
(setq-default vterm-shell (executable-find "fish"))
(setq-default explicit-shell-file-name (executable-find "fish"))
;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
;; projectile
(setq projectile-project-search-path'("~/code/""~/gits/""/etc/nixos/"))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Haskell formatting with ormolu (most reliable Haskell formatter)
;; Add NixOS profile bin to exec-path so formatters can be found
(add-to-list 'exec-path "/etc/profiles/per-user/stamno/bin")

;; CRITICAL: Enable LSP formatting in Doom
(setq +format-with-lsp t)

;; Configure LSP to use ormolu for formatting
(after! lsp-haskell
  ;; Set ormolu as the formatter (default and most stable)
  (setq lsp-haskell-formatting-provider "ormolu")

  ;; Enable LSP diagnostics (linting)
  (setq lsp-diagnostics-provider :auto)

  ;; Show diagnostics on save
  (setq lsp-modeline-diagnostics-enable t)

  ;; Auto-check on save
  (add-hook 'haskell-mode-hook
            (lambda ()
              (setq-local lsp-diagnostics-provider :flycheck)
              (flycheck-mode 1))))

;; WORKAROUND: Doom's format-on-save doesn't trigger LSP formatting properly
;; So we call lsp-format-buffer directly on save for Haskell files
(defun my/haskell-format-on-save ()
  "Format Haskell buffer with LSP before saving."
  (when (and (eq major-mode 'haskell-mode)
             (bound-and-true-p lsp-mode))
    (lsp-format-buffer)))

(add-hook 'before-save-hook #'my/haskell-format-on-save)

;; Flycheck configuration for Haskell
(after! flycheck
  (add-hook 'haskell-mode-hook #'flycheck-mode)

  ;; Load flycheck-haskell for better integration
  (eval-after-load 'flycheck
    '(add-hook 'flycheck-mode-hook #'flycheck-haskell-setup))

  ;; Check on save
  (setq flycheck-check-syntax-automatically '(save mode-enabled new-line)))

(dirvish-override-dired-mode)

;;org movement
(after! org
  (map! :map org-mode-map
        :n "M-j" #'org-metadown
        :n "M-k" #'org-metaup))

(map! :n "M-k" #'drag-stuff-up
      :n "M-j" #'drag-stuff-down
      :v "M-j" #'drag-stuff-up
      :v "M-j" #'drag-stuff-down)

(use-package! emmet-mode
  :hook ((html-mode . emmet-mode)
         (css-mode . emmet-mode)
         (web-mode . emmet-mode))
  :config
  (setq emmet-move-cursor-between-quotes t))

(after! lsp-mode
  (add-to-list 'lsp-language-id-configuration '(html-mode . "html"))
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection "vscode-html-language-server")
                    :major-modes '(html-mode)
                    :server-id 'html)))

;; Company configuration for better completion
(after! company
  ;; Reduce the time after which the company auto-completion popup opens
  (setq company-idle-delay 0.2)

  ;; Reduce the number of characters before company kicks in
  (setq company-minimum-prefix-length 1)

  ;; Show numbers for completions
  (setq company-show-numbers t)

  ;; Make company completion start automatically
  (setq company-auto-complete nil)

  ;; Show company completion even for a single candidate
  (setq company-require-match nil)

  ;; Allow free typing even when completions are shown
  (setq company-selection-wrap-around t)

  ;; Show more candidates at once
  (setq company-tooltip-limit 20)

  ;; Add company dabbrev (buffer completions) to the completion backends
  (add-to-list 'company-backends 'company-dabbrev)
  (add-to-list 'company-backends 'company-dabbrev-code)

  ;; Make dabbrev case-sensitive
  (setq company-dabbrev-downcase nil)
  (setq company-dabbrev-ignore-case nil)

  ;; Use company capf (completion-at-point-functions) backend
  (add-to-list 'company-backends 'company-capf)

  ;; Align annotations to the right tooltip border
  (setq company-tooltip-align-annotations t)

  ;; Sort completions by usage frequency
  (setq company-transformers '(company-sort-by-occurrence)))

;; Enable company-mode globally
(global-company-mode +1)

;; Key bindings for company-mode
(map! :i "C-@"    #'company-complete-common
      :i "C-SPC"  #'company-complete-common
      :i "C-n"    #'company-select-next
      :i "C-p"    #'company-select-previous)

(after! elm-mode
  ;; Basic settings
  (setq elm-format-on-save t
        elm-sort-imports-on-save t)

  ;; Add LSP hook
  (add-hook 'elm-mode-hook 'lsp)

  ;; Flycheck integration
  (require 'flycheck-elm)
  (add-hook 'flycheck-mode-hook #'flycheck-elm-setup)

  ;; Test runner configuration
  (when (featurep! :elm-test-runner)
    (require 'elm-test-runner)
    (map! :map elm-mode-map
          :localleader
          (:prefix ("t" . "test")
                   "a" #'elm-test-runner-run-all-tests
                   "c" #'elm-test-runner-run-tests-at-cursor
                   "p" #'elm-test-runner-run-tests-in-file
                   "r" #'elm-test-runner-rerun-previous)))

  ;; Main keybindings
  (map! :map elm-mode-map
        :localleader
        (:prefix ("e" . "elm")
                 "b" #'elm-compile-buffer
                 "m" #'elm-compile-main
                 "p" #'elm-package-catalog
                 "r" #'elm-repl-load
                 "R" #'elm-repl-push
                 "d" #'elm-documentation-lookup)))

;; LSP-elm specific configuration
(after! lsp-elm
  (setq lsp-elm-elm-language-server-path "elm-language-server"
        lsp-elm-elm-path "elm"
        lsp-elm-elm-format-path "elm-format"))

(use-package! lsp-tailwindcss :after lsp-mode)

;; File template
(set-file-template! "\\.elm$" :trigger "__.elm" :mode 'elm-mode)

;; Dirvish preview configuration
(after! dirvish
  ;; Enable preview
  (setq dirvish-preview-dispatchers
        '(image-preview
          gif-preview
          video-preview
          archive-preview
          pdf-preview
          html-preview
          dir-info
          info-preview
          markdown-preview
          org-preview
          text-preview))

  ;; Set preview delay
  (setq dirvish-preview-delay 0.2)

  ;; Set preview size (percentage of window)
  (setq dirvish-preview-size 0.4)

  ;; Show image properties in the preview
  (setq dirvish-show-media-properties t)

  ;; Configure keybindings
  (map! :map dirvish-mode-map
        :n "p" #'dirvish-preview-toggle  ;; Changed from dirvish-toggle-preview
        :n "TAB" #'dirvish-preview-toggle ;; Changed from dirvish-toggle-preview
        :n "h" #'dired-up-directory
        :n "l" #'dired-find-file
        :n "f" #'dirvish-file-info-menu
        :n "s" #'dirvish-quicksort
        :n "v" #'dirvish-vc-menu
        :n "y" #'dirvish-yank-menu))

;; Emacs Everywhere configuration for Wayland/Hyprland
(use-package! emacs-everywhere
  :config
  ;; Frame parameters
  (setq emacs-everywhere-frame-parameters
        '((name . "emacs-everywhere")
          (width . 80)
          (height . 24)))

  ;; Store the window address for later refocus
  (defvar my/emacs-everywhere-window-address nil)

  ;; Wayland/Hyprland - get window info via hyprctl
  (setq emacs-everywhere-app-info-function
        (lambda ()
          (let* ((json (shell-command-to-string "hyprctl activewindow -j"))
                 (data (ignore-errors (json-parse-string json :object-type 'alist))))
            (setq my/emacs-everywhere-window-address
                  (if data (alist-get 'address data) nil))
            (make-emacs-everywhere-app
             :id (if data (or (alist-get 'pid data) 0) 0)
             :class (if data (or (alist-get 'class data) "") "")
             :title (if data (or (alist-get 'title data) "") "")))))

  ;; Wayland clipboard - copy only, we handle paste ourselves
  (setq emacs-everywhere-copy-command '("wl-copy"))
  (setq emacs-everywhere-paste-command nil)
  (setq emacs-everywhere-window-focus-command nil)

  ;; Custom finish: copy, close frame, refocus, paste
  (defun my/emacs-everywhere-finish ()
    "Copy buffer, close frame, refocus original window, and paste."
    (interactive)
    (let ((text (buffer-string))
          (window-addr my/emacs-everywhere-window-address))
      ;; Copy to clipboard synchronously
      (with-temp-buffer
        (insert text)
        (call-process-region (point-min) (point-max) "wl-copy" nil 0))
      ;; Close frame
      (delete-frame)
      ;; Refocus and paste via shell script for proper timing
      (when window-addr
        (start-process-shell-command
         "emacs-everywhere-paste" nil
         (format "sleep 0.2 && hyprctl dispatch focuswindow address:%s && sleep 0.1 && wl-paste -n | wtype -"
                 window-addr)))))

  ;; Use markdown-mode instead of org-mode to avoid C-c C-c conflicts
  (setq emacs-everywhere-major-mode-function #'markdown-mode)

  ;; Keybindings
  (add-hook 'emacs-everywhere-init-hooks
            (lambda ()
              (local-set-key (kbd "C-c C-c") #'my/emacs-everywhere-finish)
              (local-set-key (kbd "C-c C-k") #'emacs-everywhere-abort)
              ;; Also bind to C-c C-s as backup
              (local-set-key (kbd "C-c C-s") #'my/emacs-everywhere-finish))))


;; Transmission BitTorrent client configuration
(after! transmission
  ;; Set the transmission daemon connection details
  ;; Default connection to localhost
  (setq transmission-host "127.0.0.1"
        transmission-service 9091  ; Default transmission port
        transmission-rpc-path "/transmission/rpc"
        transmission-username ""  ; Leave empty for default
        transmission-password "") ; Leave empty or set if auth required

  ;; Optional: Set refresh interval (in seconds)
  (setq transmission-refresh-timeout 5)

  ;; Key bindings for transmission
  (map! :map transmission-mode-map
        :n "a" #'transmission-add
        :n "d" #'transmission-remove
        :n "p" #'transmission-toggle
        :n "s" #'transmission-toggle
        :n "v" #'transmission-verify
        :n "g" #'transmission-refresh
        :n "RET" #'transmission-files
        :n "i" #'transmission-info
        :n "q" #'quit-window)

  ;; Optional: Custom faces using everblush colors
  (custom-set-faces
   '(transmission-completed ((t (:foreground "#8ccf7e")))) ; Use everblush green
   '(transmission-seeding ((t (:foreground "#67cbe7"))))   ; Use everblush cyan
   '(transmission-downloading ((t (:foreground "#e5c76b")))) ; Use everblush yellow
   '(transmission-paused ((t (:foreground "#b3b9b8"))))))  ; Use everblush white

;; Optional: Global key binding to open transmission
(map! :leader
      (:prefix ("t" . "toggle")
       :desc "Transmission" "t" #'transmission))


(use-package! gdscript-mode
  :hook (gdscript-mode . lsp-deferred))


(after! lsp-mode
  (add-to-list 'lsp-language-id-configuration '(gdscript-mode . "gdscript"))
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-tcp-connection (lambda (port) `("localhost" ,port)))
                    :major-modes '(gdscript-mode)
                    :remote? nil
                    :server-id 'gdscript)))

;; Vterm-specific optimizations
(setq vterm-max-scrollback 100000)  ; Increase scrollback for long conversations
(setq vterm-min-window-width 40)    ; Allow narrow windows

;; Optional: Only set increased scrollback for Claude buffers
