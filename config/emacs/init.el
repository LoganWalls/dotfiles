(require 'use-package)
(setopt use-package-always-ensure t)
(setopt use-package-always-defer t)

; Use lexical-binding: https://www.gnu.org/software/emacs/manual/html_node/elisp/Using-Lexical-Binding.html
(setopt lexical-binding t)

; Avoid GC-related slowdowns
(use-package gcmh
  :demand ; load immediately
  :custom
  ; Threshold of 32MB based on here: https://github.com/doomemacs/doomemacs/issues/3108#issuecomment-627537230
  (gcmh-high-cons-threshold 33554432)
  :config
  (gcmh-mode 1))

; Basic UI
(setopt use-short-answers t) ; respond y / n
(setopt inhibit-startup-screen t)
(setopt use-dialog-box nil) ; no GUI dialogs
(scroll-bar-mode -1) ; no scoll bar
(tool-bar-mode -1) ; no tool bar
(tooltip-mode -1) ; no tooltips 
(set-fringe-mode 10) ; add padding
(menu-bar-mode 1) ; use menu bar (required to make yabai work)
(setopt visual-bell t) ; no beeping
(setopt frame-inhibit-implied-resize t) ; stop UI / font size changes from changing the window size
(add-to-list 'default-frame-alist '(undecorated-round . t)) ; Remove OS window decoration 
; Set background transparency
; TODO: this feature doesn't work on macOS
; (add-to-list 'default-frame-alist '(alpha-background . 90))

(set-face-attribute 'default nil :height 180)

; Keep things tidy
(use-package no-littering
  :demand
  :config
  ; Don't put custom vars in my init.el
  (setopt custom-file (no-littering-expand-etc-file-name "custom.el"))
  ; Don't use backup files (prefer git)
  (setopt make-backup-files nil)
  ; Keep auto-saves with other tidied files
  (setopt auto-save-file-name-transforms
   `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))
)

; General config
(global-auto-revert-mode 1) ; auto update buffers when file changes on disk
(setopt history-length 40) ; Save the last 40 mini-buffer commands
(savehist-mode 1) ; Save mini-buffer commands
(save-place-mode 1) ; Remember cursor position when reopening buffers
(setopt xref-search-program ;; Prefer ripgrep, then ugrep, and fall back to regular grep.
      (cond
       ((or (executable-find "ripgrep")
            (executable-find "rg"))
        'ripgrep)
       ((executable-find "ugrep")
        'ugrep)
       (t
        'grep)))


; Smooth scrolling
(pixel-scroll-precision-mode t) 
(setopt pixel-scroll-precision-interpolate-page t)
(setopt pixel-scroll-precision-use-momentum t)

; Add window margins on the left and right
(setq-default left-margin-width 1 right-margin-width 1)
(set-window-buffer nil (current-buffer))

; NOTE: can remove this if using dirvish
; macOS `ls` doesn't work with dired, this makes it use GNU ls
(when (string= system-type "darwin")
  (setopt dired-use-ls-dired t
        insert-directory-program "gls"
        dired-listing-switches "-aBhl --group-directories-first"))

(use-package direnv
 :demand
 :config
 (direnv-mode))


; Theme
(use-package catppuccin-theme
  :demand
  :init
  (load-theme 'catppuccin :no-confirm))

; Display page-breaks as horizontal rules
; (use-package page-break-lines
;   :config
;   (page-break-lines-mode))

;; Enable vertico
(use-package vertico
  :init
  (vertico-mode)
  ; Add prompt indicator to `completing-read-multiple'.
  ; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ; Do not allow the cursor in the minibuffer prompt
  (setopt minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  (setopt read-extended-command-predicate
        #'command-completion-default-include-p)
  (setopt enable-recursive-minibuffers t)
)

(use-package marginalia
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

(use-package all-the-icons-completion
  :if (display-graphic-p)
  :demand
  :after marginalia
  :config
  (all-the-icons-completion-mode)
  :hook (marginalia-mode . all-the-icons-completion-marginalia-setup))

(use-package all-the-icons-dired
  :if (display-graphic-p)
  :demand
  :after dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package which-key
  :init
  (which-key-mode))

(use-package corfu
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-delay  0)
  (corfu-auto-prefix 2)
  (corfu-quit-no-match 'separator)
  :init
  ; Hide commands in M-x which do not apply to the current mode.
  (setopt read-extended-command-predicate #'command-completion-default-include-p) 
  (global-corfu-mode))

(use-package consult
  :bind (("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop

         ;; M-s bindings in `search-map'
         ("M-s g" . consult-git-grep)
         ("M-s /" . consult-ripgrep)
         ("M-s l" . consult-line)

         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  :init
  ;; This improves the register preview for `consult-register',
  ;; `consult-register-load', `consult-register-store' and the Emacs built-ins.
  (setopt register-preview-delay 0.5
        register-preview-function #'consult-register-format)
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)
  ;; Use Consult to select xref locations with preview
  (setopt xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  ;; Configure the :preview-key on a per-command basis using the
  ;; `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   :preview-key '(:debounce 0.4 any))
  (setopt consult-narrow-key "<"))

; TODO: orderless 


; Language-specific packages
(use-package nix-mode)

; Automatically use tree-sitter enabled major modes
(use-package treesit-auto
  :if (treesit-available-p)
  :demand
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

; JSON processing is slow, this reduces the amount of it
(fset #'jsonrpc--log-event #'ignore)
(use-package eglot
 :config
 (add-to-list 'eglot-server-programs '(nix-mode . ("nil" :initializationOptions (:formatter "alejandra"))))
 :hook ((python-base-mode . eglot-ensure)
        (rust-mode . eglot-ensure)
        (nix-mode . eglot-ensure)
        (lua-mode . eglot-ensure)
        (bash-mode . eglot-ensure)
        (dockerfile-mode . eglot-ensure)
        (html-mode . eglot-ensure)
        (css-mode . eglot-ensure)
        (js-json-mode . eglot-ensure)
        (javascript-mode . eglot-ensure)
        (typescript-ts-mode . eglot-ensure)
        (tsx-ts-mode . eglot-ensure)))
  

; Modal editing
; (use-package avy) ; TODO: fix avy; Warns about use of deprecated function `linum-mode`
(use-package goto-chg)
(use-package evil
  :demand
  :init
	(setopt
      evil-want-integration t
      evil-want-keybinding nil ; Required for evil-collection
      evil-undo-system 'undo-redo ; Use native redo
      evil-want-C-u-scroll t
      evil-want-C-d-scroll t
      evil-want-Y-yank-to-eol t)
  :config
	(evil-mode 1))
(use-package evil-collection
  :demand
  :after evil
  :custom (evil-collection-setup-minibuffer t)
  :config
  (evil-collection-init))
(use-package doom-modeline
  :demand
  :hook (after-init . doom-modeline-mode))

(use-package svg-tag-mode
  :demand
  :custom (svg-tag-tags
    '(("TODO:" . ((lambda (tag) (svg-tag-make "TODO"))))))
  :config (svg-tag-mode))

; Make wrapped lines indent
; TODO: make this only apply to already-indented items like lists
; using adaptive-wrap-extra-indent > 0 works for list items, but also
; indents lines in regular sentences. But when using 
; adaptive-wrap-extra-indent = 0, the list items are not quite indented enough
; Maybe look at this for alternative solution?
; https://github.com/jrblevin/markdown-mode/issues/388#issuecomment-621238814
; (use-package adaptive-wrap
;   :custom
;   (adaptive-wrap-extra-indent 0)
;   :hook (markdown-mode . adaptive-wrap-prefix-mode))


; (defun my/markdown-mode-setup()
;   (buffer-face-set :inherit 'variable-pitch)
;   (setq line-spacing 0.5)
;   (setq fill-column 60) ; how many characters before a line should wrap
;   (visual-line-mode t))
; (use-package markdown-mode
;   :hook (markdown-mode . my/markdown-mode-setup)
;   :custom
;     (markdown-command '("pandoc" "--from=commonmark_x" "--to=html" "--standalone" "--katex"))
;     (markdown-header-scaling t "Use different sizes for headings")
;     (markdown-header-scaling-values '(1.4 1.3 1.2 1.1 1.0 1.0))
;     (markdown-list-item-bullets '("•" "◦"))
;     (markdown-enable-math t)
;     (markdown-enable-html t)
;     (markdown-hide-markup t)
;   :config
;   (custom-theme-set-faces ; more minimal styling
;   'user
;   '(markdown-markup-face ((t (:foreground unspecified :inherit 'font-lock-comment-face))))
;   '(markdown-bold-face ((t (:foreground unspecified :weight bold :inherit 'default))))
;   '(markdown-header-face ((t (:foreground unspecified :weight bold :inherit 'default))))
;   '(markdown-math-face ((t (:foreground unspecified :inherit 'default))))
;   '(markdown-link-face ((t (:foreground unspecified :inherit 'link))))
;   '(markdown-list-face ((t (:foreground unspecified :inherit 'font-lock-comment-face))))
;   '(markdown-code-face ((t (:foreground unspecified :inherit 'default))))
;   '(markdown-metadata-key-face ((t (:foreground unspecified :inherit 'font-lock-comment-face))))
;   '(markdown-html-tag-name-face ((t (:foreground unspecified :inherit 'font-lock-comment-face))))
;   '(markdown-metadata-value-face ((t (:foreground unspecified :inherit 'default))))
;   '(markdown-gfm-checkbox-face ((t (:inherit 'font-lock-keyword-face)))))
;   (my/latex-preview-setup))

; Automatically show latex previews when the cursor is not inside the latex block
;; (use-package texfrag
;;   :custom (texfrag-preview-buffer-at-start t)
;;   :hook (markdown-mode . texfrag-mode))

;; Org-Mode
; (defun my/org-mode-setup ()
;   (org-indent-mode)
;   (variable-pitch-mode 1)
;   (auto-fill-mode 0)
;   (visual-line-mode 1))
;
; (use-package org
;   :hook (org-mode . my/org-mode-setup)
;   :custom
;     (org-ellipsis " ▾")
;     (org-hide-emphasis-markers t)
;     (org-pretty-entities t)
;     (org-log-done 'time)
;     (org-list-allow-alphabetical t)
;     (org-catch-invisible-edits 'smart)
;     (org-startup-with-latex-preview t)
;     (org-preview-latex-default-process 'dvisvgm "Use svg for latex previews")
;   :config
;   ;; Make sure org-indent face is available
;   (require 'org-indent)
;
;   ;; Ensure that anything that should be fixed-pitch in Org files appears that way
;   (set-face-attribute 'org-block nil :foreground 'unspecified :inherit 'fixed-pitch)
;   (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
;   (set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))
;   (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
;   (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
;   (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)
;   (set-face-attribute 'org-table nil :inherit 'fixed-pitch)
;
;   ;; Make headings bigger
;   (custom-theme-set-faces
;     'user
;     '(variable-pitch ((t (:family "SF Pro" :height 180))))
;     '(outline-1 ((t (:weight extra-bold :height 1.25))))
;     '(outline-2 ((t (:weight bold :height 1.15))))
;     '(outline-3 ((t (:weight bold :height 1.12))))
;     '(outline-4 ((t (:weight semi-bold :height 1.09))))
;     '(outline-5 ((t (:weight semi-bold :height 1.06))))
;     '(outline-6 ((t (:weight semi-bold :height 1.03))))
;     '(outline-8 ((t (:weight semi-bold))))
;     '(outline-9 ((t (:weight semi-bold))))
;     '(org-document-title ((t (:height 1.2)))))
;
;   ;; Replace list hyphen with dot
;   (font-lock-add-keywords 'org-mode
;                         '(("^ *\\([-]\\) "
;                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
;   (my/latex-preview-setup))


; Preview inline math fragments, but only when cursor is not inside them
; (use-package org-fragtog
;   :hook (org-mode . org-fragtog-mode))
;
; ; Same for bold / italics / special characters
; (use-package org-appear
;   :custom
;   (org-hide-emphasis-markers t)
;   (org-appear-autolinks t)
;   (org-appear-autosubmarkers t)
;   (org-appear-inside-latex t)
;   :hook (org-mode . org-appear-mode))
;
; ; Pretty tags / dates / progress bars. Config taken from nyoom emacs:
; ; https://github.com/shaunsingh/nyoom.emacs/blob/main/config.org#svg-tag-mode
; (use-package svg-tag-mode
;   :hook (org-mode . svg-tag-mode) 
;   :config
;   (defconst date-re "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}")
;   (defconst time-re "[0-9]\\{2\\}:[0-9]\\{2\\}")
;   (defconst day-re "[A-Za-z]\\{3\\}")
;   (defconst day-time-re (format "\\(%s\\)? ?\\(%s\\)?" day-re time-re))
;
;   (defun svg-progress-percent (value)
;     (svg-image (svg-lib-concat
;                 (svg-lib-progress-bar (/ (string-to-number value) 100.0)
;                                   nil :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
;                 (svg-lib-tag (concat value "%")
;                              nil :stroke 0 :margin 0)) :ascent 'center))
;
;   (defun svg-progress-count (value)
;     (let* ((seq (mapcar #'string-to-number (split-string value "/")))
;            (count (float (car seq)))
;            (total (float (cadr seq))))
;     (svg-image (svg-lib-concat
;                 (svg-lib-progress-bar (/ count total) nil
;                                       :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
;                 (svg-lib-tag value nil
;                              :stroke 0 :margin 0)) :ascent 'center)))
;
;   (setq svg-tag-tags
;         `(
;           ;; Org tags
;           (":\\([A-Za-z0-9]+\\)" . ((lambda (tag) (svg-tag-make tag))))
;           (":\\([A-Za-z0-9]+[ \-]\\)" . ((lambda (tag) tag)))
;
;           ;; Task priority
;           ("\\[#[A-Z]\\]" . ( (lambda (tag)
;                                 (svg-tag-make tag :face 'org-priority
;                                               :beg 2 :end -1 :margin 0))))
;
;           ;; Progress
;           ("\\(\\[[0-9]\\{1,3\\}%\\]\\)" . ((lambda (tag)
;                                               (svg-progress-percent (substring tag 1 -2)))))
;           ("\\(\\[[0-9]+/[0-9]+\\]\\)" . ((lambda (tag)
;                                             (svg-progress-count (substring tag 1 -1)))))
;
;           ;; TODO / DONE
;           ("TODO" . ((lambda (tag) (svg-tag-make "TODO" :face 'org-todo :inverse t :margin 0))))
;           ("DONE" . ((lambda (tag) (svg-tag-make "DONE" :face 'org-done :margin 0))))
;
;
;           ;; Citation of the form [cite:@Knuth:1984]
;           ("\\(\\[cite:@[A-Za-z]+:\\)" . ((lambda (tag)
;                                             (svg-tag-make tag
;                                                           :inverse t
;                                                           :beg 7 :end -1
;                                                           :crop-right t))))
;           ("\\[cite:@[A-Za-z]+:\\([0-9]+\\]\\)" . ((lambda (tag)
;                                                   (svg-tag-make tag
;                                                                 :end -1
;                                                                 :crop-left t))))
;
;
;           ;; Active date (with or without day name, with or without time)
;           (,(format "\\(<%s>\\)" date-re) .
;            ((lambda (tag)
;               (svg-tag-make tag :beg 1 :end -1 :margin 0))))
;           (,(format "\\(<%s \\)%s>" date-re day-time-re) .
;            ((lambda (tag)
;               (svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0))))
;           (,(format "<%s \\(%s>\\)" date-re day-time-re) .
;            ((lambda (tag)
;               (svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0))))
;
;           ;; Inactive date  (with or without day name, with or without time)
;            (,(format "\\(\\[%s\\]\\)" date-re) .
;             ((lambda (tag)
;                (svg-tag-make tag :beg 1 :end -1 :margin 0 :face 'org-date))))
;            (,(format "\\(\\[%s \\)%s\\]" date-re day-time-re) .
;             ((lambda (tag)
;                (svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0 :face 'org-date))))
;            (,(format "\\[%s \\(%s\\]\\)" date-re day-time-re) .
;             ((lambda (tag)
;                (svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0 :face 'org-date)))))))

; (use-package org-modern
;   :after org
;   :hook
;   ((org-mode . org-modern-mode)
;    (org-agenda-finalize . org-modern-agenda))
;   :custom
;   (org-modern-block-fringe t)
;   ;; (org-modern-footnote t)
;   (org-modern-hide-stars 'leading)
;   (org-modern-horizontal-rule t)
;   ;; (org-modern-internal-target t)
;   (org-modern-keyword t)
;   ;; (org-modern-radio-target t)
;   (org-modern-table t)
;   (org-modern-table-vertical 1)
;   (org-modern-table-horizontal 1)
;
;   ; These are handled by svg-tag-mode instead
;   (org-modern-label-border nil)
;   (org-modern-priority nil)
;   (org-modern-progress nil)
;   (org-modern-statistics nil)
;   (org-modern-tag nil)
;   (org-modern-timestamp nil)
;   (org-modern-todo nil))

; Notes
; (use-package denote
;   :custom
;   (denote-directory (expand-file-name "~/cyberbrain/notes/"))
;   (denote-known-keywords '("project"))
;   (denote-infer-keywords t)
;   (denote-sort-keywords t)
;   (denote-date-prompt-use-org-read-date t)
;   (denote-backlinks-show-context t)
;   :config
;   (add-hook 'dired-mode-hook #'denote-dired-mode))


; Dashboard
; (use-package dashboard
;   :custom
;   (initial-buffer-choice (lambda ()
;                            (get-buffer-create "*dashboard*")
;                            (setq dashboard-image-banner-max-height (/ (window-pixel-height) 3))
;                            (dashboard-refresh-buffer)) "Open dashboard when using emacsclient -c")
;   (dashboard-banner-logo-title "Let's get started.")
;   (dashboard-startup-banner (concat user-emacs-directory "custom/espurr.png"))
;   (dashboard-center-content t)
;   (dashboard-set-init-info t "Show number of packages and startup time")
;   :config
;   (dashboard-setup-startup-hook))

; ; Cooking recipe support for org
; (use-package org-chef
;   :commands (org-chef-insert-recipe org-chef-get-recipe-from-url))
; (custom-set-variables
;  ;; custom-set-variables was added by Custom.
;  ;; If you edit it by hand, you could mess it up, so be careful.
;  ;; Your init file should contain only one such instance.
;  ;; If there is more than one, they won't work right.
;  '(package-selected-packages nil))
; (custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 ; )
