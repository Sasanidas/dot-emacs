;;; org-toc.el --- add table of contents to org-mode files

;; Copyright (C) 2014 Sergei Nosov

;; Author: Sergei Nosov <sergei.nosov [at] gmail.com>
;; Version: 1.0
;; Keywords: org-mode org toc table of contents
;; URL: https://github.com/snosov1/org-toc

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; org-toc is a utility to have an up-to-date table of contents in the
;; org files without exporting (useful primarily for readme files on
;; GitHub).

;; To enable this functionality put into your .emacs file something
;; like

;; (add-hook 'before-save-hook 'ot-insert-toc)

;; After that, every time you'll be saving an org file the first
;; heading with a :TOC: tag will be updated with the current table of
;; contents.

;; For details, see https://github.com/snosov1/org-toc/README.org

;;; Code:

;; just in case, simple regexp "^*.*:toc:\\($\\|[^ ]*:$\\)"
(defconst ot-org-toc-regexp "^*.*:toc\\(@[0-9]\\|\\(@[0-9]@[a-zA-Z]+\\)\\)?:\\($\\|[^ ]*:$\\)"
  "Regexp to find the heading with the :toc: tag")
(defconst ot-special-chars-regexp "[][~`!@#$%^&*()+={}|\:;\"'<,>.?/]"
  "Regexp with the special characters (which are omitted in hrefs
  by GitHub)")

(defcustom ot-max-depth 2
  "Maximum depth of the headings to use in the table of
contents. The default of 2 uses only the highest level headings
and their subheadings (one and two stars)."
  :group 'org-toc)

(defcustom ot-hrefify-default "gh"
  "Default hrefify function to use."
  :group 'org-toc)

(defun ot-raw-toc ()
  "Return the \"raw\" table of contents of the current file,
i.e. simply flush everything that's not a heading."
  (let ((content (buffer-substring-no-properties
                  (point-min) (point-max))))
    (with-temp-buffer
      (insert content)
      (goto-char (point-min))
      (keep-lines "^\*")

      ;; don't include the TOC itself
      (goto-char (point-min))
      (re-search-forward ot-org-toc-regexp)
      (beginning-of-line)
      (delete-region (point) (progn (forward-line 1) (point)))

      (buffer-substring-no-properties
       (point-min) (point-max)))))

(defun ot-hrefify-gh (str)
  "Given a heading, transform it into a href using the GitHub
rules."
  (let* ((spc-fix (replace-regexp-in-string " " "-" str))
         (upcase-fix (replace-regexp-in-string "[A-Z]" 'downcase spc-fix t))
         (special-chars-fix (replace-regexp-in-string ot-special-chars-regexp "" upcase-fix t))
         )
    (concat "#" special-chars-fix)))

(defun ot-hrefify-org (str)
  "Given a heading, transform it into a href using the org-mode
rules."
  str)

(defun ot-hrefify-toc (toc hrefify)
  "Format the raw `toc' using the `hrefify' function to transform
each heading into a link."
  (with-temp-buffer
    (insert toc)
    (goto-char (point-min))

    (while
        (progn
          (when (looking-at "\\*")
            (delete-char 1)

            (while (looking-at "\\*")
              (delete-char 1)
              (insert "    "))

            (skip-chars-forward " ")
            (insert "- ")

            (let* ((beg (point))
                   (end (line-end-position))
                   (heading (buffer-substring-no-properties
                             beg end)))
              (insert "[[")
              (insert (funcall hrefify heading))
              (insert "][")
              (end-of-line)
              (insert "]]"))
            (= 0 (forward-line 1)))))

    (buffer-substring-no-properties
     (point-min) (point-max))))

(defun ot-flush-subheadings (toc max-depth)
  "Flush subheadings of the raw `toc' deeper than `max-depth'."
  (with-temp-buffer
    (insert toc)
    (goto-char (point-min))

    (let ((re "^"))
      (dotimes (i (1+ max-depth))
        (setq re (concat re "\\*")))
      (flush-lines re))

    (buffer-substring-no-properties
     (point-min) (point-max))))

(defun ot-insert-toc ()
  "Looks for a headline with the TOC tag and updates it with the
current table of contents.

To add a TOC tag, you can use the command
`org-set-tags-command'.

You can also use the following tag formats:

- TOC@2 - sets the max depth of the headlines in the table of
  contents to 2 (the default)

- TOC@2@gh - sets the max depth as in above and also uses the
  GitHub-style hrefs in the table of contents (the default). The
  other supported href style is 'org', which is the default org
  style (you can use C-c C-o to go to the headline at point)."

  (interactive)
  (when (eq major-mode 'org-mode)
    (save-excursion
      (goto-char (point-min))
      (let ((case-fold-search t))
        ;; find the first heading with the :TOC: tag
        (when (re-search-forward ot-org-toc-regexp (point-max) t)

          (let* ((tag (match-string 1))
                 (depth (if tag
                            (- (aref tag 1) ?0) ;; is there a better way to convert char to number?
                          ot-max-depth))
                 (hrefify-tag (if (and tag (>= (length tag) 4))
                                  (downcase (substring tag 3))
                                ot-hrefify-default))
                 (hrefify-string (concat "ot-hrefify-" hrefify-tag))
                 (hrefify (intern-soft hrefify-string)))
            (if hrefify
                (progn
                  (forward-line 1)

                  ;; insert newline if TOC is currently empty
                  (when (looking-at "^\\*")
                    (open-line 1))

                  ;; remove previous TOC
                  (delete-region (point)
                                 (save-excursion
                                   (search-forward-regexp "^\\*" (point-max) 0)
                                   (forward-line -1)
                                   (end-of-line)
                                   (point)))

                  (insert (ot-hrefify-toc (ot-flush-subheadings (ot-raw-toc) depth) hrefify)))
              (message (concat "Hrefify function " hrefify-string " is not found")))))))))
