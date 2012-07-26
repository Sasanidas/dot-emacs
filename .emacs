;; general configuration
(add-to-list 'load-path "~/.emacs.d")

;; ------------------------------------------------------------
;; EXTERNAL DEPENDENCIES:
;; * auto-complete
;; * ess (and hence R)

;; auto-complete mode
(when (require 'auto-complete-config nil t)
    (add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
    (ac-config-default))

;; for R statstics language
(when (require 'ess-site nil t)
  (setq ess-use-auto-complete t))
;; ------------------------------------------------------------

;; dired-x
(require 'dired-x)

;; lose tool bar
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(c-basic-offset 4)
 '(c-default-style (quote ((c-mode . "bsd") (c++-mode . "bsd") (java-mode . "java") (awk-mode . "awk") (other . "gnu"))))
 '(calendar-week-start-day 1)
 '(custom-enabled-themes (quote (tango-dark)))
 '(default-input-method "russian-computer")
 '(dired-dwim-target t)
 '(dired-listing-switches "-alh")
 '(ediff-highlight-all-diffs t)
 '(ediff-quit-hook (quote (ediff-cleanup-mess exit-recursive-edit)))
 '(ediff-split-window-function (quote split-window-horizontally))
 '(ediff-window-setup-function (quote ediff-setup-windows-plain))
 '(ido-enable-flex-matching t)
 '(ido-mode (quote buffer) nil (ido))
 '(indent-tabs-mode nil)
 '(initial-buffer-choice t)
 '(initial-major-mode (quote org-mode))
 '(initial-scratch-message nil)
 '(ls-lisp-ignore-case t)
 '(ls-lisp-verbosity nil)
 '(org-agenda-files (quote ("~/Dropbox/Private/org/")))
 '(org-capture-templates (quote (("e" "Capture expenses entry" table-line (file "~/Dropbox/Private/org/expenses.org") "| %u | %^{tag|misc|grocery|room|gas|car|sveta-stuff|sveta-cafe|lunch|dance} | %^{cost} | %^{desc} |"))))
 '(org-directory "~/Dropbox/Private/org")
 '(org-modules (quote (org-bbdb org-bibtex org-docview org-gnus org-info org-jsinfo org-habit org-irc org-mew org-mhe org-rmail org-vm org-wl org-w3m)))
 '(read-buffer-completion-ignore-case t)
 '(read-file-name-completion-ignore-case t)
 '(scroll-error-top-bottom t)
 '(tab-width 4)
 '(whitespace-style (quote (face tabs trailing space-before-tab newline indentation empty space-after-tab tab-mark newline-mark))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ediff-current-diff-A ((t (:background "white" :foreground "black"))) t)
 '(ediff-current-diff-Ancestor ((t (:background "white" :foreground "black"))))
 '(ediff-current-diff-B ((t (:background "white" :foreground "black"))) t)
 '(ediff-current-diff-C ((t (:background "white" :foreground "black"))))
 '(ediff-even-diff-A ((t (:background "antique white" :foreground "Black"))) t)
 '(ediff-even-diff-Ancestor ((t (:background "antique white" :foreground "black"))))
 '(ediff-even-diff-B ((t (:background "antique white" :foreground "black"))) t)
 '(ediff-even-diff-C ((t (:background "antique white" :foreground "Black"))))
 '(ediff-fine-diff-A ((t (:background "gainsboro" :foreground "blue"))) t)
 '(ediff-fine-diff-Ancestor ((t (:background "gainsboro" :foreground "red"))))
 '(ediff-fine-diff-B ((t (:background "gainsboro" :foreground "forest green"))) t)
 '(ediff-fine-diff-C ((t (:background "gainsboro" :foreground "purple"))))
 '(ediff-odd-diff-A ((t (:background "antique white" :foreground "black"))) t)
 '(ediff-odd-diff-Ancestor ((t (:background "antique white" :foreground "black"))))
 '(ediff-odd-diff-B ((t (:background "antique white" :foreground "Black"))) t)
 '(ediff-odd-diff-C ((t (:background "antique white" :foreground "black")))))

;; shut up the bell
(setq ring-bell-function 'ignore)

;; ediff: fine highlight by char, not words
(setq ediff-forward-word-function 'forward-char)

;; KEY BINDINGS
;; global
(global-set-key (kbd "C-x f") 'find-file)
(global-set-key (kbd "C-x C-d") 'dired)
(global-set-key [C-tab] 'ido-switch-buffer)
(global-set-key (kbd "C-x C-q") 'view-mode)
(global-set-key (kbd "C-M-p") 'previous-buffer)
(global-set-key (kbd "C-M-n") 'next-buffer)
(global-set-key (kbd "\C-c c") 'org-capture)
(global-set-key (kbd "\C-c a") 'org-agenda)

;; org-mode
(require 'org)
(add-hook 'org-mode-hook
          '(lambda ()
             ;; don't redefine C-<TAB>
             (define-key org-mode-map [C-tab]
               nil)
             ;; swap active/inactive time-stamp bindings
             (define-key org-mode-map (kbd "C-c .")
               'org-time-stamp-inactive)
             (define-key org-mode-map (kbd "C-c !")
               'org-time-stamp)))
;; enable python execution in org-mode
(require 'ob-python)
(require 'ob-R)
(setq org-default-notes-file (concat org-directory "/notes.org"))

;; dired-mode
(add-hook 'dired-mode-hook
          '(lambda()
             ;; keep default behavior in dired
             (define-key dired-mode-map (kbd "C-x C-q")
               'dired-toggle-read-only)
             ;; use global key bindings intead
             (define-key dired-mode-map (kbd "C-M-p")
               nil)
             (define-key dired-mode-map (kbd "C-M-n")
               nil)))

;; view-mode
(add-hook 'view-mode-hook
          '(lambda ()
             ;; navigation
             (define-key view-mode-map "p"
               'previous-line)
             (define-key view-mode-map "n"
               'next-line)
             (define-key view-mode-map "f"
               'forward-char)
             (define-key view-mode-map "b"
               'backward-char)))

;; enable whitespace mode for source editing modes
(require 'whitespace)
(add-hook 'c++-mode-hook
  (function (lambda ()
              (whitespace-mode t))))
(add-hook 'c-mode-hook
  (function (lambda ()
              (whitespace-mode t))))
(add-hook 'emacs-lisp-mode-hook
  (function (lambda ()
              (whitespace-mode t))))
(add-hook 'python-mode-hook
  (function (lambda ()
              (whitespace-mode t))))

;; starting emacs server
(require 'server)
(when (equal window-system 'w32)
  (defun server-ensure-safe-dir (dir) "Noop" t)) ; Suppress error "directory
                                                 ; ~/.emacs.d/server is unsafe"
                                                 ; on windows.

(unless (server-running-p) (server-start))

;; disable 'confusing' functions disabling
(put 'narrow-to-region 'disabled nil)
