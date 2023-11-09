(require 'use-package)
(setq use-package-always-ensure t)
(setq use-package-always-defer t)
; Use lexical-binding: https://www.gnu.org/software/emacs/manual/html_node/elisp/Using-Lexical-Binding.html
(setq lexical-binding t)

; Before we do anything else, let's stop the
; garbage collector from slowing us down.
(use-package gcmh
  :demand ; load immediately
  :config
  (gcmh-mode 1))


;;; Some helpful macros stolen from Doom Emacs.
(defmacro defadvice! (symbol arglist &optional docstring &rest body)
  "Define an advice called SYMBOL and add it to PLACES.
ARGLIST is as in `defun'. WHERE is a keyword as passed to `advice-add', and
PLACE is the function to which to add the advice, like in `advice-add'.
DOCSTRING and BODY are as in `defun'.
\(fn SYMBOL ARGLIST &optional DOCSTRING &rest [WHERE PLACES...] BODY\)"
  (declare (doc-string 3) (indent defun))
  (unless (stringp docstring)
    (push docstring body)
    (setq docstring nil))
  (let (where-alist)
    (while (keywordp (car body))
      (push `(cons ,(pop body) (ensure-list ,(pop body)))
            where-alist))
    `(progn
       (defun ,symbol ,arglist ,docstring ,@body)
       (dolist (targets (list ,@(nreverse where-alist)))
         (dolist (target (cdr targets))
           (advice-add target (car targets) #',symbol))))))

(defmacro undefadvice! (symbol _arglist &optional docstring &rest body)
  "Undefine an advice called SYMBOL.
This has the same signature as `defadvice!' an exists as an easy undefiner when
testing advice (when combined with `rotate-text').
\(fn SYMBOL ARGLIST &optional DOCSTRING &rest [WHERE PLACES...] BODY\)"
  (declare (doc-string 3) (indent defun))
  (let (where-alist)
    (unless (stringp docstring)
      (push docstring body))
    (while (keywordp (car body))
      (push `(cons ,(pop body) (ensure-list ,(pop body)))
            where-alist))
    `(dolist (targets (list ,@(nreverse where-alist)))
       (dolist (target (cdr targets))
         (advice-remove target #',symbol)))))


; Basic UI
(setq confirm-kill-emacs 'yes-or-no-p) ; pevent accidentally quitting the GUI
(setq use-short-answers t) ; respond y / n
(setq inhibit-startup-screen t)
(setq use-dialog-box nil) ; no GUI dialogs
(scroll-bar-mode -1) ; no scoll bar
(tool-bar-mode -1) ; no tool bar
(tooltip-mode -1) ; no tooltips 
(set-fringe-mode 10) ; add padding
(menu-bar-mode 1) ; use menu bar (required to make yabai work)
(setq visual-bell t) ; no beeping


; Remove OS window decoration 
(add-to-list 'default-frame-alist '(undecorated-round . t))
; Set background transparency
; TODO: this new feature should work, but doesn't (at least on macOS)
;; (add-to-list 'default-frame-alist '(alpha-background . 90))
(add-to-list 'default-frame-alist '(alpha . (95 . 95)))

; Keep things tidy
(use-package no-littering
  :config
  ; Keep native-comp cache with other tidied files
  (when (fboundp 'startup-redirect-eln-cache)
    (startup-redirect-eln-cache
     (convert-standard-filename
      (expand-file-name  "var/eln-cache/" user-emacs-directory))))
  ; Don't put custom vars in my init.el
  (setq custom-file (no-littering-expand-etc-file-name "custom.el"))
  ; Don't use backup files (prefer git)
  (setq make-backup-files nil) 
  ; Keep auto-saves with other tidied files
  (setq auto-save-file-name-transforms
   `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))
)

; General config
(global-auto-revert-mode 1) ; auto update buffers when file changes on disk
(setq history-length 40) ; Save the last 40 mini-buffer commands
(savehist-mode 1) ; Save mini-buffer commands
(save-place-mode 1) ; Remember cursor position when reopening buffers
(setq xref-search-program ;; Prefer ripgrep, then ugrep, and fall back to regular grep.
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
(setq pixel-scroll-precision-interpolate-page t)
(setq pixel-scroll-precision-use-momentum t)

; Add window margins on the left and right
(setq-default left-margin-width 1 right-margin-width 1)
(set-window-buffer nil (current-buffer))
; Add window margins (top / bottom)
; TODO: this is not working
(use-package topspace
  :custom
  (topspace-center-position 1)
  :config
  (global-topspace-mode 1))


; Dired
; Use GNU ls on macOS
; NOTE: can remove this if using dirvish
(when (string= system-type "darwin")
  (setq dired-use-ls-dired t
        insert-directory-program "gls"
        dired-listing-switches "-aBhl --group-directories-first"))


; Display page-breaks as horizontal rules
(use-package page-break-lines
  :config
  (page-break-lines-mode))

; Theme
(use-package doom-themes
  :config
  (load-theme 'doom-tokyo-night t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config)
  ; Font
  (custom-theme-set-faces ; more minimal colors
    'user
    '(variable-pitch ((t (:family "SF Pro" :height 180))))
    '(default ((t (:family "Liga SFMono Nerd Font" :height 180))))
    '(fixed-pitch ((t (:family "Liga SFMono Nerd Font" :height 180))))
    '(link ((t (:background nil))))))

; Mode line
(use-package lambda-line
  :after doom-themes
  ;; :straight (:type git :host github :repo "lambda-emacs/lambda-line") 
  :custom
  (require 'all-the-icons)
  ;; (lambda-line-icon-time t) ;; requires ClockFace font (see below)
  ;; (lambda-line-clockface-update-fontset "ClockFaceRect") ;; set clock icon
  (lambda-line-position 'bottom) ;; Set position of status-line 
  (lambda-line-abbrev t) ;; abbreviate major modes
  (lambda-line-hspace "  ")  ;; add some cushion
  (lambda-line-prefix t) ;; use a prefix symbol
  (lambda-line-prefix-padding nil) ;; no extra space for prefix 
  (lambda-line-status-invert nil)  ;; no invert colors
  (lambda-line-gui-ro-symbol  " ") ;; symbols
  (lambda-line-gui-mod-symbol " ") 
  (lambda-line-gui-rw-symbol  " ") 
  (lambda-line-space-top +.50)  ;; padding on top and bottom of line
  (lambda-line-space-bottom -.50)
  :config
  ; Use theme colors
  (set-face-attribute 'lambda-line-active-status-RW nil :foreground (doom-color 'green))
  (set-face-attribute 'lambda-line-active-status-MD nil :foreground (doom-color 'red))
  (set-face-attribute 'lambda-line-active-status-RO nil :foreground (doom-color 'yellow))
  (set-face-attribute 'lambda-line-visual-bell nil :background 'unspecified :inherit 'doom-themes-visual-bell)
  (lambda-line-mode) 
  ;; set divider line in footer
  (when (eq lambda-line-position 'top)
    (setq-default mode-line-format (list "%_"))
    (setq mode-line-format (list "%_"))))

; Modal editing
(use-package avy)
(use-package which-key
  :init
  (which-key-mode))

; Evil
(use-package goto-chg)
(use-package evil
  :init
	(setq
      evil-want-integration t
      evil-want-keybinding nil ; Required for evil-collection
	     evil-undo-system 'undo-redo ; Use native redo
	     evil-want-C-u-scroll t
	     evil-want-C-d-scroll t
      evil-want-Y-yank-to-eol t)
  :config
	(evil-mode 1))
(use-package evil-collection
  :after (evil avy)
  :custom (evil-collection-setup-minibuffer t)
  :config
  (require 'avy)
  (evil-collection-init)
  (evil-define-key nil evil-motion-state-map
  "s" 'avy-goto-word-1-below
  "S" 'avy-goto-word-1-above))


;;;;;;;;;;;;;;;;;;;;;;;
; Completion
(use-package vertico
  :init
  (vertico-mode)
  ;; Different scroll margin
  ;; (setq vertico-scroll-margin 0)
  ;; Show more candidates
  ;; (setq vertico-count 20)
  ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  (setq vertico-cycle t))
(use-package emacs
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))

;; Use the `orderless' completion style
(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Either bind `marginalia-cycle' globally or only in the minibuffer
  :bind (("M-A" . marginalia-cycle)
         :map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init
  ;; Must be in the :init section of use-package such that the mode gets
  ;; enabled right away. Note that this forces loading the package.
  (marginalia-mode))

(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  (corfu-quit-no-match 'separator)    ;; Never quit, even if there is no match
  ;; (corfu-separator ?\s)          ;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect-first nil)    ;; Disable candidate preselection
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin

  ;; Recommended: Enable Corfu globally.
  ;; This is recommended since Dabbrev can be used globally (M-/).
  ;; See also `corfu-excluded-modes'.
  :init
  (global-corfu-mode))

;; A few more useful configurations...
(use-package emacs
  :init
  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)

  ;; Emacs 28: Hide commands in M-x which do not apply to the current mode.
  ;; Corfu commands are hidden, since they are not supposed to be used via M-x.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete))
;;;;;;;;;;;;;;;;;;;;;;;

;; General fuzzy-finding and filtering
(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c h" . consult-history)
         ("C-c m" . consult-mode-command)
         ("C-c k" . consult-kmacro)
         ;; C-x bindings (ctl-x-map)
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer

         ;; Custom M-# bindings for fast register access
         ;; ("M-#" . consult-register-load)
         ;; ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ;; ("C-M-#" . consult-register)

         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop

         ;; M-g bindings (goto-map)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)

         ;; M-s bindings (search-map)
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-ripgrep)
         ("M-s G" . consult-git-grep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)

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

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key (kbd "M-."))
  ;; (setq consult-preview-key (list (kbd "<S-down>") (kbd "<S-up>")))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key (kbd "M-.")
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; (kbd "C-+")

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;; There are multiple reasonable alternatives to chose from.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;;;; 3. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 4. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
)

(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  :config

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))


(defun my/latex-preview-setup()
  (require 'org)

  ; Make latex previews similar in size to the body text
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.8))
  
  ; Use tectonic instead of pdflatex
  (setq-default org-latex-pdf-process '("tectonic -Z shell-escape --outdir=%o %f"))

  ; Prettier latex fragments 
  ; (stolen from https://tecosaur.github.io/emacs-config/config.html#latex-fragments)
  ;; (require 'org-src)
  ;; (add-to-list 'org-src-block-faces '("latex" (:inherit default :extend t)))
  ;; (setq org-highlight-latex-and-related '(native script entities))
  (setq org-format-latex-header "
      \\documentclass{article}
      \\usepackage[usenames]{xcolor}

      \\usepackage[T1]{fontenc}

      \\usepackage{booktabs}

      \\pagestyle{empty}             % do not remove
      % The settings below are copied from fullpage.sty
      \\setlength{\\textwidth}{\\paperwidth}
      \\addtolength{\\textwidth}{-3cm}
      \\setlength{\\oddsidemargin}{1.5cm}
      \\addtolength{\\oddsidemargin}{-2.54cm}
      \\setlength{\\evensidemargin}{\\oddsidemargin}
      \\setlength{\\textheight}{\\paperheight}
      \\addtolength{\\textheight}{-\\headheight}
      \\addtolength{\\textheight}{-\\headsep}
      \\addtolength{\\textheight}{-\\footskip}
      \\addtolength{\\textheight}{-3cm}
      \\setlength{\\topmargin}{1.5cm}
      \\addtolength{\\topmargin}{-2.54cm}
      % my custom stuff
      \\usepackage[nofont,plaindd]{bmc-maths}
      \\usepackage{arev}
      ")
    (setq org-format-latex-options
          (plist-put org-format-latex-options :background "Transparent")))

; Make wrapped lines indent
; TODO: make this only apply to already-indented items like lists
; using adaptive-wrap-extra-indent > 0 works for list items, but also
; indents lines in regular sentences. But when using 
; adaptive-wrap-extra-indent = 0, the list items are not quite indented enough
; Maybe look at this for alternative solution?
; https://github.com/jrblevin/markdown-mode/issues/388#issuecomment-621238814
(use-package adaptive-wrap
  :custom
  (adaptive-wrap-extra-indent 0)
  :hook (markdown-mode . adaptive-wrap-prefix-mode))

(defun my/markdown-mode-setup()
  (buffer-face-set :inherit 'variable-pitch)
  (setq line-spacing 0.5)
  (setq fill-column 60) ; how many characters before a line should wrap
  (visual-line-mode t))
(use-package markdown-mode
  :hook (markdown-mode . my/markdown-mode-setup)
  :custom
    (markdown-command '("pandoc" "--from=commonmark_x" "--to=html" "--standalone" "--katex"))
    (markdown-header-scaling t "Use different sizes for headings")
    (markdown-header-scaling-values '(1.4 1.3 1.2 1.1 1.0 1.0))
    (markdown-list-item-bullets '("•" "◦"))
    (markdown-enable-math t)
    (markdown-enable-html t)
    (markdown-hide-markup t)
  :config
  (custom-theme-set-faces ; more minimal styling
  'user
  '(markdown-markup-face ((t (:foreground unspecified :inherit 'font-lock-comment-face))))
  '(markdown-bold-face ((t (:foreground unspecified :weight bold :inherit 'default))))
  '(markdown-header-face ((t (:foreground unspecified :weight bold :inherit 'default))))
  '(markdown-math-face ((t (:foreground unspecified :inherit 'default))))
  '(markdown-link-face ((t (:foreground unspecified :inherit 'link))))
  '(markdown-list-face ((t (:foreground unspecified :inherit 'font-lock-comment-face))))
  '(markdown-code-face ((t (:foreground unspecified :inherit 'default))))
  '(markdown-metadata-key-face ((t (:foreground unspecified :inherit 'font-lock-comment-face))))
  '(markdown-html-tag-name-face ((t (:foreground unspecified :inherit 'font-lock-comment-face))))
  '(markdown-metadata-value-face ((t (:foreground unspecified :inherit 'default))))
  '(markdown-gfm-checkbox-face ((t (:inherit 'font-lock-keyword-face)))))
  (my/latex-preview-setup))

;; Wrap lines at fill-column in visual line mode
(use-package visual-fill-column
 :hook (visual-line-mode . visual-fill-column-mode)
 :custom (visual-fill-column-center-text t))

; Automatically show latex previews when the cursor is not inside the latex block
;; (use-package texfrag
;;   :custom (texfrag-preview-buffer-at-start t)
;;   :hook (markdown-mode . texfrag-mode))

;; Org-Mode
(defun my/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (auto-fill-mode 0)
  (visual-line-mode 1))

(use-package org
  :hook (org-mode . my/org-mode-setup)
  :custom
    (org-ellipsis " ▾")
    (org-hide-emphasis-markers t)
    (org-pretty-entities t)
    (org-log-done 'time)
    (org-list-allow-alphabetical t)
    (org-catch-invisible-edits 'smart)
    (org-startup-with-latex-preview t)
    (org-preview-latex-default-process 'dvisvgm "Use svg for latex previews")
  :config
  ;; Make sure org-indent face is available
  (require 'org-indent)

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground 'unspecified :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil :inherit 'fixed-pitch)

  ;; Make headings bigger
  (custom-theme-set-faces
    'user
    '(variable-pitch ((t (:family "SF Pro" :height 180))))
    '(outline-1 ((t (:weight extra-bold :height 1.25))))
    '(outline-2 ((t (:weight bold :height 1.15))))
    '(outline-3 ((t (:weight bold :height 1.12))))
    '(outline-4 ((t (:weight semi-bold :height 1.09))))
    '(outline-5 ((t (:weight semi-bold :height 1.06))))
    '(outline-6 ((t (:weight semi-bold :height 1.03))))
    '(outline-8 ((t (:weight semi-bold))))
    '(outline-9 ((t (:weight semi-bold))))
    '(org-document-title ((t (:height 1.2)))))

  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                        '(("^ *\\([-]\\) "
                          (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
  (my/latex-preview-setup))


; Preview inline math fragments, but only when cursor is not inside them
(use-package org-fragtog
  :hook (org-mode . org-fragtog-mode))

; Same for bold / italics / special characters
(use-package org-appear
  :custom
  (org-hide-emphasis-markers t)
  (org-appear-autolinks t)
  (org-appear-autosubmarkers t)
  (org-appear-inside-latex t)
  :hook (org-mode . org-appear-mode))

; Pretty tags / dates / progress bars. Config taken from nyoom emacs:
; https://github.com/shaunsingh/nyoom.emacs/blob/main/config.org#svg-tag-mode
(use-package svg-tag-mode
  :hook (org-mode . svg-tag-mode) 
  :config
  (defconst date-re "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}")
  (defconst time-re "[0-9]\\{2\\}:[0-9]\\{2\\}")
  (defconst day-re "[A-Za-z]\\{3\\}")
  (defconst day-time-re (format "\\(%s\\)? ?\\(%s\\)?" day-re time-re))

  (defun svg-progress-percent (value)
    (svg-image (svg-lib-concat
                (svg-lib-progress-bar (/ (string-to-number value) 100.0)
                                  nil :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
                (svg-lib-tag (concat value "%")
                             nil :stroke 0 :margin 0)) :ascent 'center))

  (defun svg-progress-count (value)
    (let* ((seq (mapcar #'string-to-number (split-string value "/")))
           (count (float (car seq)))
           (total (float (cadr seq))))
    (svg-image (svg-lib-concat
                (svg-lib-progress-bar (/ count total) nil
                                      :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
                (svg-lib-tag value nil
                             :stroke 0 :margin 0)) :ascent 'center)))

  (setq svg-tag-tags
        `(
          ;; Org tags
          (":\\([A-Za-z0-9]+\\)" . ((lambda (tag) (svg-tag-make tag))))
          (":\\([A-Za-z0-9]+[ \-]\\)" . ((lambda (tag) tag)))

          ;; Task priority
          ("\\[#[A-Z]\\]" . ( (lambda (tag)
                                (svg-tag-make tag :face 'org-priority
                                              :beg 2 :end -1 :margin 0))))

          ;; Progress
          ("\\(\\[[0-9]\\{1,3\\}%\\]\\)" . ((lambda (tag)
                                              (svg-progress-percent (substring tag 1 -2)))))
          ("\\(\\[[0-9]+/[0-9]+\\]\\)" . ((lambda (tag)
                                            (svg-progress-count (substring tag 1 -1)))))

          ;; TODO / DONE
          ("TODO" . ((lambda (tag) (svg-tag-make "TODO" :face 'org-todo :inverse t :margin 0))))
          ("DONE" . ((lambda (tag) (svg-tag-make "DONE" :face 'org-done :margin 0))))


          ;; Citation of the form [cite:@Knuth:1984]
          ("\\(\\[cite:@[A-Za-z]+:\\)" . ((lambda (tag)
                                            (svg-tag-make tag
                                                          :inverse t
                                                          :beg 7 :end -1
                                                          :crop-right t))))
          ("\\[cite:@[A-Za-z]+:\\([0-9]+\\]\\)" . ((lambda (tag)
                                                  (svg-tag-make tag
                                                                :end -1
                                                                :crop-left t))))


          ;; Active date (with or without day name, with or without time)
          (,(format "\\(<%s>\\)" date-re) .
           ((lambda (tag)
              (svg-tag-make tag :beg 1 :end -1 :margin 0))))
          (,(format "\\(<%s \\)%s>" date-re day-time-re) .
           ((lambda (tag)
              (svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0))))
          (,(format "<%s \\(%s>\\)" date-re day-time-re) .
           ((lambda (tag)
              (svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0))))

          ;; Inactive date  (with or without day name, with or without time)
           (,(format "\\(\\[%s\\]\\)" date-re) .
            ((lambda (tag)
               (svg-tag-make tag :beg 1 :end -1 :margin 0 :face 'org-date))))
           (,(format "\\(\\[%s \\)%s\\]" date-re day-time-re) .
            ((lambda (tag)
               (svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0 :face 'org-date))))
           (,(format "\\[%s \\(%s\\]\\)" date-re day-time-re) .
            ((lambda (tag)
               (svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0 :face 'org-date)))))))

(use-package org-modern
  :after org
  :hook
  ((org-mode . org-modern-mode)
   (org-agenda-finalize . org-modern-agenda))
  :custom
  (org-modern-block-fringe t)
  ;; (org-modern-footnote t)
  (org-modern-hide-stars 'leading)
  (org-modern-horizontal-rule t)
  ;; (org-modern-internal-target t)
  (org-modern-keyword t)
  ;; (org-modern-radio-target t)
  (org-modern-table t)
  (org-modern-table-vertical 1)
  (org-modern-table-horizontal 1)

  ; These are handled by svg-tag-mode instead
  (org-modern-label-border nil)
  (org-modern-priority nil)
  (org-modern-progress nil)
  (org-modern-statistics nil)
  (org-modern-tag nil)
  (org-modern-timestamp nil)
  (org-modern-todo nil))

; Notes
(use-package denote
  :custom
  (denote-directory (expand-file-name "~/cyberbrain/notes/"))
  (denote-known-keywords '("project"))
  (denote-infer-keywords t)
  (denote-sort-keywords t)
  (denote-date-prompt-use-org-read-date t)
  (denote-backlinks-show-context t)
  :config
  (add-hook 'dired-mode-hook #'denote-dired-mode))


; Dashboard
(use-package dashboard
  :custom
  (initial-buffer-choice (lambda ()
                           (get-buffer-create "*dashboard*")
                           (setq dashboard-image-banner-max-height (/ (window-pixel-height) 3))
                           (dashboard-refresh-buffer)) "Open dashboard when using emacsclient -c")
  (dashboard-banner-logo-title "Let's get started.")
  (dashboard-startup-banner (concat user-emacs-directory "custom/espurr.png"))
  (dashboard-center-content t)
  (dashboard-set-init-info t "Show number of packages and startup time")
  :config
  (dashboard-setup-startup-hook))


; Enhanced rust support
(use-package rustic
  :init
  (setq rustic-lsp-client 'eglot))

; Cooking recipe support for org
(use-package org-chef
  :commands (org-chef-insert-recipe org-chef-get-recipe-from-url))

; HTML Exports
; Stolen from https://tecosaur.github.io/emacs-config/config.html#html-export
(define-minor-mode org-fancy-html-export-mode
  "Toggle my fabulous org export tweaks. While this mode itself does a little bit,
the vast majority of the change in behaviour comes from switch statements in:
 - `org-html-template-fancier'
 - `org-html--build-meta-info-extended'
 - `org-html-src-block-collapsable'
 - `org-html-block-collapsable'
 - `org-html-table-wrapped'
 - `org-html--format-toc-headline-colapseable'
 - `org-html--toc-text-stripped-leaves'
 - `org-export-html-headline-anchor'"
  :global t
  :init-value t
  (if org-fancy-html-export-mode
      (setq org-html-style-default org-html-style-fancy
            org-html-meta-tags #'org-html-meta-tags-fancy
            org-html-checkbox-type 'html-span)
    (setq org-html-style-default org-html-style-plain
          org-html-meta-tags #'org-html-meta-tags-default
          org-html-checkbox-type 'html)))
(with-eval-after-load 'ox-html

; Nice CSS
(setq org-html-style-plain org-html-style-default
      org-html-htmlize-output-type 'css
      org-html-doctype "html5"
      org-html-html5-fancy t)
(defun org-html-reload-fancy-style ()
  (interactive)
  (setq org-html-style-fancy
        (concat (f-read-text (expand-file-name "custom/org-export/html/header.html" user-emacs-directory))
                "<script>\n"
                (f-read-text (expand-file-name "custom/org-export/html/main.js" user-emacs-directory))
                "</script>\n<style>\n"
                (f-read-text (expand-file-name "custom/org-export/html/main.min.css" user-emacs-directory))
                "</style>"))
  (when org-fancy-html-export-mode
    (setq org-html-style-default org-html-style-fancy)))
(org-html-reload-fancy-style)

; Collapsable blocks
(defvar org-html-export-collapsed nil)
(eval '(cl-pushnew '(:collapsed "COLLAPSED" "collapsed" org-html-export-collapsed t)
                   (org-export-backend-options (org-export-get-backend 'html))))
(add-to-list 'org-default-properties "EXPORT_COLLAPSED")

; Nicer code blocks with clipboard copy button
(defadvice! org-html-src-block-collapsable (orig-fn src-block contents info)
  "Wrap the usual <pre> block in a <details>"
  :around #'org-html-src-block
  (if (or (not org-fancy-html-export-mode) (bound-and-true-p org-msg-export-in-progress))
      (funcall orig-fn src-block contents info)
    (let* ((properties (cadr src-block))
           (lang (mode-name-to-lang-name
                  (plist-get properties :language)))
           (name (plist-get properties :name))
           (ref (org-export-get-reference src-block info))
           (collapsed-p (member (or (org-export-read-attribute :attr_html src-block :collapsed)
                                    (plist-get info :collapsed))
                                '("y" "yes" "t" t "true" "all"))))
      (format
       "<details id='%s' class='code'%s><summary%s>%s</summary>
<div class='gutter'>
<a href='#%s'>#</a>
<button title='Copy to clipboard' onclick='copyPreToClipbord(this)'>⎘</button>\
</div>
%s
</details>"
       ref
       (if collapsed-p "" " open")
       (if name " class='named'" "")
       (concat
        (when name (concat "<span class=\"name\">" name "</span>"))
        "<span class=\"lang\">" lang "</span>")
       ref
       (if name
           (replace-regexp-in-string (format "<pre\\( class=\"[^\"]+\"\\)? id=\"%s\">" ref) "<pre\\1>"
                                     (funcall orig-fn src-block contents info))
         (funcall orig-fn src-block contents info))))))

(defun mode-name-to-lang-name (mode)
  (or (cadr (assoc mode
                   '(("asymptote" "Asymptote")
                     ("awk" "Awk")
                     ("C" "C")
                     ("clojure" "Clojure")
                     ("css" "CSS")
                     ("D" "D")
                     ("ditaa" "ditaa")
                     ("dot" "Graphviz")
                     ("calc" "Emacs Calc")
                     ("emacs-lisp" "Emacs Lisp")
                     ("fortran" "Fortran")
                     ("gnuplot" "gnuplot")
                     ("haskell" "Haskell")
                     ("hledger" "hledger")
                     ("java" "Java")
                     ("js" "Javascript")
                     ("latex" "LaTeX")
                     ("ledger" "Ledger")
                     ("lisp" "Lisp")
                     ("lilypond" "Lilypond")
                     ("lua" "Lua")
                     ("matlab" "MATLAB")
                     ("mscgen" "Mscgen")
                     ("ocaml" "Objective Caml")
                     ("octave" "Octave")
                     ("org" "Org mode")
                     ("oz" "OZ")
                     ("plantuml" "Plantuml")
                     ("processing" "Processing.js")
                     ("python" "Python")
                     ("R" "R")
                     ("ruby" "Ruby")
                     ("sass" "Sass")
                     ("scheme" "Scheme")
                     ("screen" "Gnu Screen")
                     ("sed" "Sed")
                     ("sh" "shell")
                     ("sql" "SQL")
                     ("sqlite" "SQLite")
                     ("forth" "Forth")
                     ("io" "IO")
                     ("J" "J")
                     ("makefile" "Makefile")
                     ("maxima" "Maxima")
                     ("perl" "Perl")
                     ("picolisp" "Pico Lisp")
                     ("scala" "Scala")
                     ("shell" "Shell Script")
                     ("ebnf2ps" "ebfn2ps")
                     ("cpp" "C++")
                     ("abc" "ABC")
                     ("coq" "Coq")
                     ("groovy" "Groovy")
                     ("bash" "bash")
                     ("csh" "csh")
                     ("ash" "ash")
                     ("dash" "dash")
                     ("ksh" "ksh")
                     ("mksh" "mksh")
                     ("posh" "posh")
                     ("ada" "Ada")
                     ("asm" "Assembler")
                     ("caml" "Caml")
                     ("delphi" "Delphi")
                     ("html" "HTML")
                     ("idl" "IDL")
                     ("mercury" "Mercury")
                     ("metapost" "MetaPost")
                     ("modula-2" "Modula-2")
                     ("pascal" "Pascal")
                     ("ps" "PostScript")
                     ("prolog" "Prolog")
                     ("simula" "Simula")
                     ("tcl" "tcl")
                     ("tex" "LaTeX")
                     ("plain-tex" "TeX")
                     ("verilog" "Verilog")
                     ("vhdl" "VHDL")
                     ("xml" "XML")
                     ("nxml" "XML")
                     ("conf" "Configuration File"))))
      mode))
(defun org-html-block-collapsable (orig-fn block contents info)
  "Wrap the usual block in a <details>"
  (if (or (not org-fancy-html-export-mode) (bound-and-true-p org-msg-export-in-progress))
      (funcall orig-fn block contents info)
    (let ((ref (org-export-get-reference block info))
          (type (pcase (car block)
                  ('property-drawer "Properties")))
          (collapsed-default (pcase (car block)
                               ('property-drawer t)
                               (_ nil)))
          (collapsed-value (org-export-read-attribute :attr_html block :collapsed))
          (collapsed-p (or (member (org-export-read-attribute :attr_html block :collapsed)
                                   '("y" "yes" "t" t "true"))
                           (member (plist-get info :collapsed) '("all")))))
      (format
       "<details id='%s' class='code'%s>
<summary%s>%s</summary>
<div class='gutter'>\
<a href='#%s'>#</a>
<button title='Copy to clipboard' onclick='copyPreToClipbord(this)'>⎘</button>\
</div>
%s\n
</details>"
       ref
       (if (or collapsed-p collapsed-default) "" " open")
       (if type " class='named'" "")
       (if type (format "<span class='type'>%s</span>" type) "")
       ref
       (funcall orig-fn block contents info)))))

(advice-add 'org-html-example-block   :around #'org-html-block-collapsable)
(advice-add 'org-html-fixed-width     :around #'org-html-block-collapsable)
(advice-add 'org-html-property-drawer :around #'org-html-block-collapsable)

; Add additional code styling to htmlize export
(autoload #'highlight-numbers--turn-on "highlight-numbers")
(add-hook 'htmlize-before-hook #'highlight-numbers--turn-on)

; Hide table overflows
(defadvice! org-html-table-wrapped (orig-fn table contents info)
  "Wrap the usual <table> in a <div>"
  :around #'org-html-table
  (if (or (not org-fancy-html-export-mode) (bound-and-true-p org-msg-export-in-progress))
      (funcall orig-fn table contents info)
    (let* ((name (plist-get (cadr table) :name))
           (ref (org-export-get-reference table info)))
      (format "<div id='%s' class='table'>
<div class='gutter'><a href='#%s'>#</a></div>
<div class='tabular'>
%s
</div>\
</div>"
              ref ref
              (if name
                  (replace-regexp-in-string (format "<table id=\"%s\"" ref) "<table"
                                            (funcall orig-fn table contents info))
                (funcall orig-fn table contents info))))))

; Collapsable Table of Contents
(defadvice! org-html--format-toc-headline-colapseable (orig-fn headline info)
  "Add a label and checkbox to `org-html--format-toc-headline's usual output,
to allow the TOC to be a collapseable tree."
  :around #'org-html--format-toc-headline
  (if (or (not org-fancy-html-export-mode) (bound-and-true-p org-msg-export-in-progress))
      (funcall orig-fn headline info)
    (let ((id (or (org-element-property :CUSTOM_ID headline)
                  (org-export-get-reference headline info))))
      (format "<input type='checkbox' id='toc--%s'/><label for='toc--%s'>%s</label>"
              id id (funcall orig-fn headline info)))))
(defadvice! org-html--toc-text-stripped-leaves (orig-fn toc-entries)
  "Remove label"
  :around #'org-html--toc-text
  (if (or (not org-fancy-html-export-mode) (bound-and-true-p org-msg-export-in-progress))
      (funcall orig-fn toc-entries)
    (replace-regexp-in-string "<input [^>]+><label [^>]+>\\(.+?\\)</label></li>" "\\1</li>"
                              (funcall orig-fn toc-entries))))

; Make verbatim different than code
(setq org-html-text-markup-alist
      '((bold . "<b>%s</b>")
        (code . "<code>%s</code>")
        (italic . "<i>%s</i>")
        (strike-through . "<del>%s</del>")
        (underline . "<span class=\"underline\">%s</span>")
        (verbatim . "<kbd>%s</kbd>")))

; Add anchors for each heading
(defun org-export-html-headline-anchor (text backend info)
  (when (and (org-export-derived-backend-p backend 'html)
             (not (org-export-derived-backend-p backend 're-reveal))
             org-fancy-html-export-mode)
    (unless (bound-and-true-p org-msg-export-in-progress)
      (replace-regexp-in-string
       "<h\\([0-9]\\) id=\"\\([a-z0-9-]+\\)\">\\(.*[^ ]\\)<\\/h[0-9]>" ; this is quite restrictive, but due to `org-reference-contraction' I can do this
       "<h\\1 id=\"\\2\">\\3<a aria-hidden=\"true\" href=\"#\\2\">#</a> </h\\1>"
       text))))
(add-to-list 'org-export-filter-headline-functions
             'org-export-html-headline-anchor)
;;;;;; End HTML Export Config ;;;;;;
)
