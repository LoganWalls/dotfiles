(require 'use-package)
(setq use-package-always-ensure t)
; Use lexical-binding: https://www.gnu.org/software/emacs/manual/html_node/elisp/Using-Lexical-Binding.html
(setq lexical-binding t)

; Before we do anything else, let's stop the
; garbage collector from slowing us down.
(use-package gcmh
  :demand ; load immediately
  :config
  (gcmh-mode 1)
)

; Basic UI
(setq confirm-kill-emacs 'yes-or-no-p) ; pevent accidentally quitting the GUI
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
; I'd like to have top / bottom too, but there's
; no simple way to do it in emacs right now
(setq-default left-margin-width 1 right-margin-width 1)
(set-window-buffer nil (current-buffer))

; Dired
; Use GNU ls on macOS
(when (string= system-type "darwin")
  (setq dired-use-ls-dired t
        insert-directory-program "gls"
        dired-listing-switches "-aBhl --group-directories-first"))

; Add colors and icons (stolen from: https://github.com/doomemacs/doomemacs/blob/master/modules/emacs/dired/config.el)
; FIXME or replace with dirvish (dirvish also handles gnu ls)
;; (use-package diredfl
;;   :hook (dired-mode . diredfl-mode))
;; (use-package all-the-icons-dired
;;   :hook (dired-mode . all-the-icons-dired-mode)
;;   :config
;;   ;; HACK Fixes #1929: icons break file renaming in Emacs 27+, because the icon
;;   ;;      is considered part of the filename, so we disable icons while we're in
;;   ;;      wdired-mode.
;;   (defvar +wdired-icons-enabled -1)
;;
;;   ;; display icons with colors
;;   (setq all-the-icons-dired-monochrome nil)
;;
;;   (defadvice +dired-disable-icons-in-wdired-mode-a (&rest _)
;;     :before #'wdired-change-to-wdired-mode
;;     (setq-local +wdired-icons-enabled (if all-the-icons-dired-mode 1 -1))
;;     (when all-the-icons-dired-mode
;;       (all-the-icons-dired-mode -1)))
;;
;;   (defadvice +dired-restore-icons-after-wdired-mode-a (&rest _)
;;     :after #'wdired-change-to-dired-mode
;;     (all-the-icons-dired-mode +wdired-icons-enabled)))

; Font
(custom-theme-set-faces
 'user
 '(variable-pitch ((t (:family "SF Pro" :height 180))))
 '(default ((t (:family "Liga SFMono Nerd Font" :height 180))))
 '(fixed-pitch ((t (:family "Liga SFMono Nerd Font" :height 180)))))


(use-package ligature
  :config
  ;; Enable all Cascadia and Fira Code ligatures in programming modes
  ;; (ligature-set-ligatures 'prog-mode
  ;;                       '(;; == === ==== => =| =>>=>=|=>==>> ==< =/=//=// =~
  ;;                         ;; =:= =!=
  ;;                         ("=" (rx (+ (or ">" "<" "|" "/" "~" ":" "!" "="))))
  ;;                         ;; ;; ;;;
  ;;                         (";" (rx (+ ";")))
  ;;                         ;; && &&&
  ;;                         ("&" (rx (+ "&")))
  ;;                         ;; !! !!! !. !: !!. != !== !~
  ;;                         ("!" (rx (+ (or "=" "!" "\." ":" "~"))))
  ;;                         ;; ?? ??? ?:  ?=  ?.
  ;;                         ("?" (rx (or ":" "=" "\." (+ "?"))))
  ;;                         ;; %% %%%
  ;;                         ("%" (rx (+ "%")))
  ;;                         ;; |> ||> |||> ||||> |] |} || ||| |-> ||-||
  ;;                         ;; |->>-||-<<-| |- |== ||=||
  ;;                         ;; |==>>==<<==<=>==//==/=!==:===>
  ;;                         ("|" (rx (+ (or ">" "<" "|" "/" ":" "!" "}" "\]"
  ;;                                         "-" "=" ))))
  ;;                         ;; \\ \\\ \/
  ;;                         ("\\" (rx (or "/" (+ "\\"))))
  ;;                         ;; ++ +++ ++++ +>
  ;;                         ("+" (rx (or ">" (+ "+"))))
  ;;                         ;; :: ::: :::: :> :< := :// ::=
  ;;                         (":" (rx (or ">" "<" "=" "//" ":=" (+ ":"))))
  ;;                         ;; // /// //// /\ /* /> /===:===!=//===>>==>==/
  ;;                         ("/" (rx (+ (or ">"  "<" "|" "/" "\\" "\*" ":" "!"
  ;;                                         "="))))
  ;;                         ;; .. ... .... .= .- .? ..= ..<
  ;;                         ("\." (rx (or "=" "-" "\?" "\.=" "\.<" (+ "\."))))
  ;;                         ;; -- --- ---- -~ -> ->> -| -|->-->>->--<<-|
  ;;                         ("-" (rx (+ (or ">" "<" "|" "~" "-"))))
  ;;                         ;; *> */ *)  ** *** ****
  ;;                         ("*" (rx (or ">" "/" ")" (+ "*"))))
  ;;                         ;; <> <!-- <|> <: <~ <~> <~~ <+ <* <$ </  <+> <*>
  ;;                         ;; <$> </> <|  <||  <||| <|||| <- <-| <-<<-|-> <->>
  ;;                         ;; <<-> <= <=> <<==<<==>=|=>==/==//=!==:=>
  ;;                         ;; << <<< <<<<
  ;;                         ("<" (rx (+ (or "\+" "\*" "\$" "<" ">" ":" "~"  "!"
  ;;                                         "-"  "/" "|" "="))))
  ;;                         ;; >: >- >>- >--|-> >>-|-> >= >== >>== >=|=:=>>
  ;;                         ;; >> >>> >>>>
  ;;                         (">" (rx (+ (or ">" "<" "|" "/" ":" "=" "-"))))
  ;;                         ;; #: #= #! #( #? #[ #{ #_ #_( ## ### #####
  ;;                         ("#" (rx (or ":" "=" "!" "(" "\?" "\[" "{" "_(" "_"
  ;;                                      (+ "#"))))
  ;;                         ;; ~~ ~~~ ~=  ~-  ~@ ~> ~~>
  ;;                         ("~" (rx (or ">" "=" "-" "@" "~>" (+ "~"))))
  ;;                         ;; __ ___ ____ _|_ __|____|_
  ;;                         ("_" (rx (+ (or "_" "|"))))
  ;;                         ;; Fira code: 0xFF 0x12
  ;;                         ("0" (rx (and "x" (+ (in "A-F" "a-f" "0-9")))))
  ;;                         ;; Fira code:
  ;;                         "Fl"  "Tl"  "fi"  "fj"  "fl"  "ft"
  ;;                         ;; The few not covered by the regexps.
  ;;                         "{|"  "[|"  "]#"  "(*"  "}#"  "$>"  "^="))
  ;; Enables ligature checks globally in all buffers.
  (global-ligature-mode t))

; Display page-breaks as horizontal rules
(use-package page-break-lines
  :config
  (page-break-lines-mode))


; Theme
(use-package doom-themes
  :after lambda-line
  :config
  (load-theme 'doom-tokyo-night t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; (use-package lambda-themes
;;   :custom
;;   (lambda-themes-set-italic-comments t)
;;   (lambda-themes-set-italic-keywords t)
;;   (lambda-themes-set-variable-pitch t) 
;;   :config
;;   (load-theme 'lambda-dark t))

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
  (set-face-attribute 'lambda-line-visual-bell nil :inherit 'doom-themes-visual-bell)
  (lambda-line-mode) 
  ;; set divider line in footer
  (when (eq lambda-line-position 'top)
    (setq-default mode-line-format (list "%_"))
    (setq mode-line-format (list "%_"))))

; Modal editing
(use-package avy)
(use-package multiple-cursors)
(use-package which-key
  :init
  (which-key-mode))

; Meow
(defmacro nt--call-negative (form)
  `(let ((current-prefix-arg -1))
     (call-interactively ,form)))
(use-package meow
  :after avy
  :init 
  (require 'avy)
  (require 'view)
  (defun nt-insert-at-cursor ()
    (interactive)
    (if meow--temp-normal
        (progn
          (message "Quit temporary normal mode")
          (meow--switch-state 'motion))
      (meow--cancel-selection)
      (meow--switch-state 'insert)))
  (defun nt-negative-find ()
    (interactive)
    (nt--call-negative 'meow-find))
  (defun nt-negative-till ()
    (interactive)
    (nt--call-negative 'meow-till))
  (defun meow-setup ()
    (setq 
      meow-cheatsheet-layout meow-cheatsheet-layout-qwerty
      ; Disable numeric hints
      meow-expand-hint-remove-delay 2.0  ; Show hints for longer
      meow-expand-hint-counts '((word . 0) ; No hints when moving by words
                               (line . 10)
                               (block . 10)
                               (find . 10)
                               (till . 10)) 
      ; Use characters themselves to describe pairs
      meow-char-thing-table '((?\( . round)
                              (?\) . round)
                              (?\[ . square)
                              (?\] . square)
                              (?\{ . curly)
                              (?\} . curly)
                              (?\' . string)
                              (?e . symbol)
                              (?w . window)
                              (?b . buffer)
                              (?p . paragraph)
                              (?l . line)
                              (?f . defun)
                              (?s . sentence))
      meow-selection-command-fallback '((meow-change . meow-change-char)
                                        (meow-kill . meow-backward-delete)
                                        (meow-cancel-selection . keyboard-quit)
                                        (meow-pop-selection . meow-pop-grab)
                                        (meow-beacon-change . meow-beacon-change-char)))

    ;; (setq meow-goto-keymap (make-keymap))
    ;; (meow-define-state goto
    ;;   "meow state for interacting with smartparens"
    ;;   :lighter " [GOTO]"
    ;;   :keymap meow-goto-keymap)
    ;;
    ;; ;; meow-define-state creates the variable
    ;; ;; (setq meow-cursor-type-paren 'hollow)
    ;;
    ;; (meow-define-keys 'goto
    ;;   '("<escape>" . meow-normal-mode)
    ;;   '("g" . meow-goto-line)
    ;;   '("l" . move-end-of-line)
    ;;   '("h" . move-beginning-of-line)
    ;;   '("s" . beginning-of-line-text))

    (meow-motion-overwrite-define-key
     '("j" . meow-next)
     '("k" . meow-prev)
     '("<escape>" . ignore))
    (meow-leader-define-key
     ;; SPC j/k will run the original command in MOTION state.
     '("j" . "H-j")
     '("k" . "H-k")
     ;; Use SPC (0-9) for digit arguments.
     '("1" . meow-digit-argument)
     '("2" . meow-digit-argument)
     '("3" . meow-digit-argument)
     '("4" . meow-digit-argument)
     '("5" . meow-digit-argument)
     '("6" . meow-digit-argument)
     '("7" . meow-digit-argument)
     '("8" . meow-digit-argument)
     '("9" . meow-digit-argument)
     '("0" . meow-digit-argument)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet))
    (meow-normal-define-key
     '("0" . meow-expand-0)
     '("9" . meow-expand-9)
     '("8" . meow-expand-8)
     '("7" . meow-expand-7)
     '("6" . meow-expand-6)
     '("5" . meow-expand-5)
     '("4" . meow-expand-4)
     '("3" . meow-expand-3)
     '("2" . meow-expand-2)
     '("1" . meow-expand-1)
     '("-" . negative-argument)
     '(";" . meow-reverse)
     '("," . meow-inner-of-thing)
     '("." . meow-bounds-of-thing)
     '("[" . meow-beginning-of-thing)
     '("]" . meow-end-of-thing)
     '("{" . backward-paragraph)
     '("}" . forward-paragraph)
     '("a" . meow-append)
     '("A" . meow-open-below)
     '("b" . meow-back-word)
     '("B" . meow-back-symbol)
     '("c" . meow-change)
     '("d" . meow-kill)
     '("D" . meow-C-k)
     '("e" . meow-mark-word)
     '("E" . meow-mark-symbol)
     '("g" . meow-goto-line)
     '("G" . meow-grab)
     '("h" . meow-left)
     '("H" . meow-left-expand)
     '("i" . meow-insert)
     '("I" . meow-open-above)
     '("j" . meow-next)
     '("J" . meow-next-expand)
     '("k" . meow-prev)
     '("K" . meow-prev-expand)
     '("l" . meow-right)
     '("L" . meow-right-expand)
     '("m" . meow-join)
     '("n" . meow-search)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("p" . meow-yank)
     '("P" . meow-replace)
     '("q" . meow-cancel-selection)
     '("Q" . meow-quit)
     '("r" . meow-replace)
     '("R" . meow-swap-grab)
     '("u" . meow-undo)
     '("U" . undo-redo)
     '("v" . meow-visit)
     '("w" . meow-next-word)
     '("W" . meow-next-symbol)
     '("x" . meow-line)
     '("X" . meow-goto-line)
     '("y" . meow-save)
     '("Y" . meow-sync-grab)
     '("z" . meow-pop-selection)
     '("'" . repeat)
     '("<escape>" . meow-cancel-selection))
  ; Find
  (meow-normal-define-key
   '("f" . meow-find)
   '("F" . nt-negative-find)
   '("s" . avy-goto-word-1-below)
   '("S" . avy-goto-word-1-above)
   '("t" . meow-till)
   '("T" . nt-negative-till)
   '("/" . meow-visit))
  ; Scrolling
  (meow-normal-define-key
   '("M-[" . View-scroll-half-page-backward)  
   '("M-]" . View-scroll-half-page-forward)))

  ; Mode line
  ;; ((normal . " 🞄")
  ;;  (motion . " ➜")
  ;;  (keypad . " ")
  ;;  (insert . " ")
  ;;  (beacon . " ⇶"))

  :config 
  (meow-setup)
  (meow-global-mode 1)
)

; Evil
;; (use-package goto-chg)
;; (use-package evil
;;   :init
;; 	(setq
;;       evil-want-integration t
;;       evil-want-keybinding nil ; Required for evil-collection
;; 	     evil-undo-system 'undo-redo ; Use native redo
;; 	     evil-want-C-u-scroll t
;; 	     evil-want-C-d-scroll t
;;       evil-want-Y-yank-to-eol t)
;;   :config
;; 	(evil-mode 1))
;; (use-package evil-collection
;;   :after (evil avy)
;;   :custom (evil-collection-setup-minibuffer t)
;;   :config
;;   (require 'avy)
;;   (evil-collection-init)
;;   (evil-define-key nil evil-motion-state-map
;;   "s" 'avy-goto-word-1-below
;;   "S" 'avy-goto-word-1-above))


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
    (org-preview-latex-default-process 'dvisvgm)
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

  ; Make latex previews similar in size to the body text
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.8))
  ; Use svg for latex previews
  
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

; Automatically show latex previews when the cursor is not inside the latex block
(use-package org-fragtog
  :hook (org-mode . org-fragtog-mode))

; Same for bold / italics / special characters
(use-package org-appear
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
  (initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")) "Open dashboard when using emacsclient -c")
  (dashboard-banner-logo-title "Let's get started.")
  (dashboard-startup-banner (concat user-emacs-directory "resources/bulbasaur.png"))
  (dashboard-center-content t)
  (dashboard-set-init-info t "Show number of packages and startup time")
  :config
  ;; (setq dashboard-image-banner-max-height (/ (window-pixel-height) 4))
  (setq dashboard-image-banner-max-height 252)
  (dashboard-setup-startup-hook))


; Enhanced rust support
(use-package rustic
  :init
  (setq rustic-lsp-client 'eglot)
)

; Cooking recipe support for org
(use-package org-chef
  :commands (org-chef-insert-recipe org-chef-get-recipe-from-url))


