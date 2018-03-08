;; -*- coding: utf-8 -*-
;;; cpio-dired.el --- UI definition à la dired.
;	$Id: cpio-dired.el,v 1.1.4.3 2018/03/08 06:10:12 doug Exp $	

;; COPYRIGHT

;; Copyright © 2017, 2018 Douglas Lewan, d.lewan2000@gmail.com.
;; All rights reserved.
;; 
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; Author: Douglas Lewan (d.lewan2000@gmail.com)
;; Maintainer: -- " --
;; Created: 2017 Dec 01
;; Version: 
;; Keywords: cpio, cpio-mode, dired

;;; Commentary:

;;; Documentation:

;;; Code:



;;
;; Dependencies
;; 


;; 
;; Vars
;; 

(defvar *cpio-dired-permission-flags-regexp* dired-permission-flags-regexp
  "Regular expression to match the permission flags in `ls -l'.")

;; (defvar dired-sort-by-date-regexp
;;   (concat "\\(\\`\\| \\)-[^- ]*t"
;; 	  ;; `dired-ls-sorting-switches' after -t overrides -t.
;; 	  "[^ " dired-ls-sorting-switches "]*"
;; 	  "\\(\\(\\`\\| +\\)\\(--[^ ]+\\|-[^- t"
;; 	  dired-ls-sorting-switches "]+\\)\\)* *$")
;;   "Regexp recognized by Dired to set `by date' mode.")

;; (defvar dired-sort-by-name-regexp
;;   (concat "\\`\\(\\(\\`\\| +\\)\\(--[^ ]+\\|"
;; 	  "-[^- t" dired-ls-sorting-switches "]+\\)\\)* *$")
;;   "Regexp recognized by Dired to set `by name' mode.")

;; (defvar dired-sort-inhibit nil
;;   "Non-nil means the Dired sort command is disabled.
;; The idea is to set this buffer-locally in special Dired buffers.")


(defvar *mon-re* (concat "jan\\|feb\\|mar\\|apr\\|may\\|jun\\|"
			 "jul\\|aug\\|sep\\|oct\\|nov\\|dec"))
(setq *mon-re* (concat "jan\\|feb\\|mar\\|apr\\|may\\|jun\\|"
		       "jul\\|aug\\|sep\\|oct\\|nov\\|dec"))

(defvar *cpio-dired-date-time-regexp* ()
  "RE to match the date/time field in ls -l.")
(setq *cpio-dired-date-time-regexp*  (concat "\\(?:"
					     *mon-re*
					     "\\)"
					     "\\s-+"
					     "[[:digit:]]\\{2\\}"
					     "\\s-+"
					     "\\(?:"
					     "[[:digit:]]\\{2\\}"
					     ":"
					     "[[:digit:]]\\{2\\}"
					     "\\|"
					     "[[:digit:]]\\{4\\}"
					     "\\)"))
(defvar *cpio-dired-entry-regexp* (concat ".."
					  "\\("
					      *cpio-dired-permission-flags-regexp*
					  "\\)"
					  "\\s-+"
					  "[[:digit:]]+" ;nlinks
					  "\\s-+"
					  "\\("
					      "[[:alnum:]]+" ;user
					  "\\)"
					  "\\s-+"
					  "\\("
					      "[[:alnum:]]+" ;group
					  "\\)"
					  "\\s-+"
					  "[[:digit:]]+" ;filesize
					  "\\s-+"
					  "\\("
					      *cpio-dired-date-time-regexp*
					  "\\)"
					  "\\s-+"
					  "\\("
					      "[[:graph:]]+"
					  "\\)"
					  )
  "Regular expression to match an entry's line in cpio-dired-mode")
(setq *cpio-dired-entry-regexp* (concat ".."
					  "\\("
					      "[-dpstrwx]\\{10\\}"
					  "\\)"
					  "\\s-+"
					  "[[:digit:]]+" ;nlinks
					  "\\s-+"
					  "\\("
					      "[[:alnum:]]+" ;user
					  "\\)"
					  "\\s-+"
					  "\\("
					      "[[:alnum:]]+" ;group
					  "\\)"

					  "\\s-+"
					  "[[:digit:]]+" ;filesize
					  "\\s-+"
					  "\\("
					      *cpio-dired-date-time-regexp*
					  "\\)"
					  "\\s-+"
					  "\\("
					      "[[:graph:]]+"
					  "\\)"
					  ))

(defvar *cpio-dired-mode-idx*      1
  "Index of the mode match in *cpio-dired-entry-regexp*.")
(setq *cpio-dired-mode-idx* 1)

(defvar *cpio-dired-user-idx*      2
  "Index of the user match in *cpio-dired-entry-regexp*.")
(setq *cpio-dired-user-idx* 2)

(defvar *cpio-dired-group-idx*     3
  "Index of the group match in *cpio-dired-entry-regexp*.")
(setq *cpio-dired-group-idx* 3)

(defvar *cpio-dired-date/time-idx* 4
  "Index of the date/time match in *cpio-dired-entry-regexp*.")
(setq *cpio-dired-date/time-idx* 4)

(defvar *cpio-dired-name-idx*      5
  "Index of the entry name match in *cpio-dired-entry-regexp*.")
(setq *cpio-dired-name-idx* 5)

(defconst cpio-dired-marker-char ?*		; the answer is 42
  ;; so that you can write things like
  ;; (let ((cpio-dired-marker-char ?X))
  ;;    ;; great code using X markers ...
  ;;    )
  ;; For example, commands operating on two sets of files, A and B.
  ;; Or marking files with digits 0-9.  This could implicate
  ;; concentric sets or an order for the marked files.
  ;; The code depends on dynamic scoping on the marker char.
  "In cpio-dired, the current mark character.
This is what the do-commands look for, and what the mark-commands store.")

(defvar cpio-dired-del-marker ?D
  "Character used to flag entries for deletion.")

(defvar cpio-dired-re-inode-size "[0-9 \t]*"
  "Regexp for optional initial inode and file size as made by `ls -i -s'.")

;; These regexps must be tested at beginning-of-line, but are also
;; used to search for next matches, so neither omitting "^" nor
;; replacing "^" by "\n" (to make it slightly faster) will work.

(defvar cpio-dired-re-mark "^[^ \n]")
;; "Regexp matching a marked line.
;; Important: the match ends just after the marker."
(defvar cpio-dired-re-maybe-mark "^. ")
;; The [^:] part after "d" and "l" is to avoid confusion with the
;; DOS/Windows-style drive letters in directory names, like in "d:/foo".
(defvar cpio-dired-re-dir (concat cpio-dired-re-maybe-mark cpio-dired-re-inode-size "d[^:]"))
(defvar cpio-dired-re-sym (concat cpio-dired-re-maybe-mark cpio-dired-re-inode-size "l[^:]"))
(defvar cpio-dired-re-exe;; match ls permission string of an executable file
  (mapconcat (function
	      (lambda (x)
		(concat cpio-dired-re-maybe-mark cpio-dired-re-inode-size x)))
	     '("-[-r][-w][xs][-r][-w].[-r][-w]."
	       "-[-r][-w].[-r][-w][xs][-r][-w]."
	       "-[-r][-w].[-r][-w].[-r][-w][xst]")
	     "\\|"))
(defvar cpio-dired-re-perms "[-bcdlps][-r][-w].[-r][-w].[-r][-w].")
(defvar cpio-dired-re-dot "^.* \\.\\.?/?$")
(defvar cpio-dired-font-lock-keywords
  (list
   ;;
   ;; Dired marks.
   (list cpio-dired-re-mark '(0 cpio-dired-mark-face))
   ;;
   ;; We make heavy use of MATCH-ANCHORED, since the regexps don't identify the
   ;; entry name itself.  We search for Dired defined regexps, and then use the
   ;; Dired defined function `cpio-dired-move-to-entry-name' before searching for the
   ;; simple regexp ".+".  It is that regexp which matches the entry name.
   ;;
   ;; Marked entries.
   (list (concat "^[" (char-to-string cpio-dired-marker-char) "]")
         '(".+" (cpio-dired-move-to-entry-name) nil (0 cpio-dired-marked-face)))
   ;;
   ;; Flagged entries.
   (list (concat "^[" (char-to-string cpio-dired-del-marker) "]")
         '(".+" (cpio-dired-move-to-entry-name) nil (0 cpio-dired-flagged-face)))
   ;; People who are paranoid about security would consider this more
   ;; important than other things such as whether it is a directory.
   ;; But we don't want to encourage paranoia, so our default
   ;; should be what's most useful for non-paranoids. -- rms.
   ;; 
   ;; However, we don't need to highlight the entry name, only the
   ;; permissions, to win generally.  -- fx.
   ;; Fixme: we could also put text properties on the permission
   ;; fields with keymaps to frob the permissions, somewhat a la XEmacs.
   (list (concat cpio-dired-re-maybe-mark cpio-dired-re-inode-size
		 "[-d]....\\(w\\)....")	; group writable
	 '(1 cpio-dired-perm-write-face))
   (list (concat cpio-dired-re-maybe-mark cpio-dired-re-inode-size
		 "[-d].......\\(w\\).")	; world writable
	 '(1 cpio-dired-perm-write-face))
   ;;
   ;; Subdirectories.
   (list cpio-dired-re-dir
	 '(".+" (cpio-dired-move-to-entry-name) nil (0 cpio-dired-directory-face)))
   ;;
   ;; Symbolic links.
   (list cpio-dired-re-sym
	 '(".+" (cpio-dired-move-to-entry-name) nil (0 cpio-dired-symlink-face)))
   ;;
   ;; Entrys suffixed with `completion-ignored-extensions'.
   '(eval .
     ;; It is quicker to first find just an extension, then go back to the
     ;; start of that entry name.  So we do this complex MATCH-ANCHORED form.
     (list (concat "\\(" (regexp-opt completion-ignored-extensions) "\\|#\\)$")
	   '(".+" (cpio-dired-move-to-entry-name) nil (0 cpio-dired-ignored-face))))
   ;;
   ;; Entrys suffixed with `completion-ignored-extensions'
   ;; plus a character put in by -F.
   '(eval .
     (list (concat "\\(" (regexp-opt completion-ignored-extensions)
		   "\\|#\\)[*=|]$")
	   '(".+" (progn
		    (end-of-line)
		    ;; If the last character is not part of the entry-name,
		    ;; move back to the start of the entry-name
		    ;; so it can be fontified.
		    ;; Otherwise, leave point at the end of the line;
		    ;; that way, nothing is fontified.
		    (unless (get-text-property (1- (point)) 'mouse-face)
		      (cpio-dired-move-to-entry-name)))
	     nil (0 cpio-dired-ignored-face))))
   ;;
   ;; Explicitly put the default face on entry names ending in a colon to
   ;; avoid fontifying them as directory header.
   (list (concat cpio-dired-re-maybe-mark cpio-dired-re-inode-size cpio-dired-re-perms ".*:$")
	 '(".+" (cpio-dired-move-to-entry-name) nil (0 'default)))
   ;;
   ;; Directory headers.
   ;;;; (list cpio-dired-subdir-regexp '(1 cpio-dired-header-face))
)
  "Additional expressions to highlight in cpio-dired mode.")

(defvar cpio-entry-name ()
  "Name of the entry whose contents are being edited.")

(defconst *cpio-dirline-re* "^..d"
  "Regular expression to match an entry for a directory.")

;;
;; Customizations
;;
(defcustom cpio-try-names t
  "Specify whether or not to try finding user and group names."
  :options (list t nil)
  :type 'boolean
  :safe t)

(defgroup cpio-dired-faces nil
  "Faces used by Dired."
  :group 'dired
  :group 'faces)

(defface cpio-dired-header
  '((t (:inherit font-lock-type-face)))
  "Face used for directory headers."
  :group 'cpio-dired-faces
  :version "22.1")
(defvar cpio-dired-header-face 'cpio-dired-header
  "Face name used for directory headers.")

(defface cpio-dired-mark
  '((t (:inherit font-lock-constant-face)))
  "Face used for Dired marks."
  :group 'cpio-dired-faces
  :version "22.1")
(defvar cpio-dired-mark-face 'cpio-dired-mark
  "Face name used for Dired marks.")

(defface cpio-dired-marked
  '((t (:inherit warning)))
  "Face used for marked files."
  :group 'cpio-dired-faces
  :version "22.1")
(defvar cpio-dired-marked-face 'cpio-dired-marked
  "Face name used for marked files.")

(defface cpio-dired-flagged
  '((t (:inherit error)))
  "Face used for files flagged for deletion."
  :group 'cpio-dired-faces
  :version "22.1")
(defvar cpio-dired-flagged-face 'cpio-dired-flagged
  "Face name used for files flagged for deletion.")

(defface cpio-dired-warning
  ;; Inherit from font-lock-warning-face since with min-colors 8
  ;; font-lock-comment-face is not colored any more.
  '((t (:inherit font-lock-warning-face)))
  "Face used to highlight a part of a buffer that needs user attention."
  :group 'cpio-dired-faces
  :version "22.1")
(defvar cpio-dired-warning-face 'cpio-dired-warning
  "Face name used for a part of a buffer that needs user attention.")

(defface cpio-dired-perm-write
  '((((type w32 pc)) :inherit default)  ;; These default to rw-rw-rw.
    ;; Inherit from font-lock-comment-delimiter-face since with min-colors 8
    ;; font-lock-comment-face is not colored any more.
    (t (:inherit font-lock-comment-delimiter-face)))
  "Face used to highlight permissions of group- and world-writable files."
  :group 'cpio-dired-faces
  :version "22.2")
(defvar cpio-dired-perm-write-face 'cpio-dired-perm-write
  "Face name used for permissions of group- and world-writable files.")

(defface cpio-dired-directory
  '((t (:inherit font-lock-function-name-face)))
  "Face used for subdirectories."
  :group 'cpio-dired-faces
  :version "22.1")
(defvar cpio-dired-directory-face 'cpio-dired-directory
  "Face name used for subdirectories.")

(defface cpio-dired-symlink
  '((t (:inherit font-lock-keyword-face)))
  "Face used for symbolic links."
  :group 'cpio-dired-faces
  :version "22.1")
(defvar cpio-dired-symlink-face 'cpio-dired-symlink
  "Face name used for symbolic links.")

(defface cpio-dired-ignored
  '((t (:inherit shadow)))
  "Face used for files suffixed with `completion-ignored-extensions'."
  :group 'cpio-dired-faces
  :version "22.1")
(defvar cpio-dired-ignored-face 'cpio-dired-ignored
  "Face name used for files suffixed with `completion-ignored-extensions'.")

(defcustom cpio-dired-trivial-filenames dired-trivial-filenames
  "Regexp of entries to skip when finding the first meaningful entry of a directory."
  :group 'cpio-dired
  :version "22.1")


;; 
;; Library
;; 

(defun cpio-dired-get-entry-name ()
  "Get the entry name on the current line."
  (let ((fname "cpio-dired-get-filename"))
    (save-excursion
      (beginning-of-line)
      (if (looking-at *cpio-dired-entry-regexp*)
	  (match-string *cpio-dired-name-idx*)))))

(defun cpio-contents-buffer-name (name)
  "Return the name of the buffer that would/does hold the contents of entry NAME.
CAVEAT: Yes, there's a possibility of a collision here.
However, that would mean that you're editing 
more than one archive, each containing entries of the same name
more than one of whose contents you are currently editing.
Run more than one instance of emacs to avoid such collisions."
  (let ((fname "cpio-contents-buffer-name"))
    (concat name " (in cpio archive)")))

;; 
;; Commands
;; 
;; e .. f		dired-find-file
;; RET		dired-find-file
(defun cpio-dired-find-entry ()
  "In a cpio UI buffer, visit the contents of the entry named on this line.
Return the buffer containing those contents."
  (interactive)
  (let* ((fname "cpio-dired-find-entry")
	 (find-file-run-dired t)
	 (entry-name (cpio-dired-get-entry-name))
	 (target-buffer))
    (cond ((null entry-name)
	   (message "%s(): Could not get entry name." fname))
	  ((setq target-buffer (get-buffer-create (cpio-contents-buffer-name entry-name)))
	   (cab-register target-buffer *cab-parent*)
	   (with-current-buffer target-buffer
	     (cond ((or (/= 0 (1- (point)))
			(= 0 (length (buffer-string))))
		    (insert (cpio-contents entry-name))
		    ;; (setq buffer-read-only t)
		    (goto-char (point-min)))
		   (t t))
	     (make-variable-buffer-local 'cpio-entry-name)
	     (setq cpio-entry-name entry-name)
	     (set-buffer-modified-p nil)
	     (cpio-entry-contents-mode)
	     )
	   (pop-to-buffer target-buffer))
	   ((null target-buffer)
	    (error "%s(): Could not get a buffer for entry [[%s]]." fname))
	   (t
	    (error "%s(): Impossible condition." fname)))))

;; C-o		dired-display-file
(defun cpio-dired-display-entry ()
  "In a cpio UI buffer, display the entry on the current line in another window."
  (interactive)
  (let ((fname "cpio-dired-display-entry")
	(target-buffer (cpio-dired-find-entry)))
    (with-current-buffer target-buffer
      (setq buffer-read-only t))
    (pop-to-buffer target-buffer)))
;; C-t		Prefix Command
;; ESC		Prefix Command
;; SPC		dired-next-line
(defun cpio-dired-next-line (arg)
  "In a cpio UI buffer, move down ARG lines then position at the entry's name.
Optional prefix ARG says how many lines to move; default is one line."
  (interactive "p")
  (let ((fname "cpio-dired-next-line"))
    (forward-line arg)
    (cpio-dired-move-to-entry-name)))

;; !		dired-do-shell-command
(defun cpio-dired-do-shell-command (command &optional arg file-list)
  ;; I'm not sure this one makes reasonable sense.
  ;; Certainly, you could run a filter on the entry's contents,
  ;; but I can't see a way to truly treat an entry like a file in that way.
  "Run a shell command COMMAND on the marked entries.
If no entries are marked or a numeric prefix arg is given,
the next ARG entries are used.  Just C-u means the current entry.
The prompt mentions the entry(s) or the marker, as appropriate.

If there is a `*' in COMMAND, surrounded by whitespace, this runs
COMMAND just once with the entire entry list substituted there.

If there is no `*', but there is a `?' in COMMAND, surrounded by
whitespace, this runs COMMAND on each entry individually with the
entry name substituted for `?'.

Otherwise, this runs COMMAND on each entry individually with the
entry name added at the end of COMMAND (separated by a space).

`*' and `?' when not surrounded by whitespace have no special
significance for `dired-do-shell-command', and are passed through
normally to the shell, but you must confirm first.

If you want to use `*' as a shell wildcard with whitespace around
it, write `*""' in place of just `*'.  This is equivalent to just
`*' in the shell, but avoids Dired's special handling.

If COMMAND ends in `&', `;', or `;&', it is executed in the
background asynchronously, and the output appears in the buffer
`*Async Shell Command*'.  When operating on multiple entries and COMMAND
ends in `&', the shell command is executed on each entry in parallel.
However, when COMMAND ends in `;' or `;&' then commands are executed
in the background on each entry sequentially waiting for each command
to terminate before running the next command.  You can also use
`dired-do-async-shell-command' that automatically adds `&'.

Otherwise, COMMAND is executed synchronously, and the output
appears in the buffer `*Shell Command Output*'.

This feature does not try to redisplay Dired buffers afterward, as
there's no telling what entries COMMAND may have changed.
Type M-x dired-do-redisplay to redisplay the marked entries.

When COMMAND runs, its working directory is the top-level directory
of the Dired buffer, so output entries usually are created there
instead of in a subdir.

In a noninteractive call (from Lisp code), you must specify
the list of entry names explicitly with the ENTRY-LIST argument, which
can be produced by `dired-get-marked-entries', for example."
  (interactive
   (let ((files (dired-get-marked-files t current-prefix-arg)))
     (list
      ;; Want to give feedback whether this file or marked files are used:
      (dired-read-shell-command "& on %s: " current-prefix-arg files)
      current-prefix-arg
      files)))
  (let ((fname "cpio-dired-do-shell-command"))
    (error "%s() is not yet implemented" fname)))
;; #		dired-flag-auto-save-files
(defun cpio-dired-flag-auto-save-files (unflag-p)
  "Flag for deletion entries whose names suggest that they come from auto save files.
A prefix argument says to unmark or unflag those entries instead."
  (interactive "P")
  (let ((fname "cpio-dired-flag-auto-save-files")
	)
    (error "%s() is not yet implemented" fname)
    ))
;; $		dired-hide-subdir
(defun cpio-dired-hide-subdir (arg)
  ;; Does this really make sense here?
  "Hide or unhide the current subdirectory and move to next directory.
Optional prefix arg is a repeat factor.
Use M-x dired-hide-all to (un)hide all directories."
  (interactive "p")
  (let ((fname "cpio-dired-hide-subdir"))
    (error "%s() is not yet implemented" fname)))
;; %		Prefix Command
;; &		dired-do-async-shell-command
(defun cpio-dired-do-async-shell-command (command &optional arg entry-list)
  ;; I don't know if this makes sense.
  "Run a shell command COMMAND on the marked entries asynchronously.

Like `dired-do-shell-command', but adds `&' at the end of COMMAND
to execute it asynchronously.

When operating on multiple entries, asynchronous commands
are executed in the background on each entry in parallel.
In shell syntax this means separating the individual commands
with `&'.  However, when COMMAND ends in `;' or `;&' then commands
are executed in the background on each entry sequentially waiting
for each command to terminate before running the next command.
In shell syntax this means separating the individual commands with `;'.

The output appears in the buffer `*Async Shell Command*'."
  (interactive
   (let ((files (dired-get-marked-files t current-prefix-arg)))
     (list
      ;; Want to give feedback whether this file or marked files are used:
      (dired-read-shell-command "& on %s: " current-prefix-arg files)
      current-prefix-arg
      files)))
  (let ((fname "cpio-dired-do-async-shell-command"))
    (error "%s() is not yet implemented" fname)))
;; (		dired-hide-details-mode
(defun cpio-dired-hide-details-mode (&optional arg)
  ;; N.B. This is a minor mode.
  "Toggle visibility of detailed information in current Dired buffer.
When this minor mode is enabled, details such as file ownership and
permissions are hidden from view.

See options: `cpio-dired-hide-details-hide-symlink-targets' and
`cpio-dired-hide-details-hide-information-lines'."
  (interactive "p")
  (let ((fname "cpio-dired-hide-details-mode"))
    (error "%s() is not yet `implemented" fname)))
;; *		Prefix Command
;; +		dired-create-directory
(defun cpio-dired-create-directory (directory)
  ;; Does this make meaningful sense?
  "Create a directory called DIRECTORY.
If DIRECTORY already exists, signal an error."
  (interactive
   (list (read-file-name "Create directory: " (dired-current-directory))))
  (let ((fname "cpio-dired-create-directory"))
    (error "%s() is not yet implemented" fname)))
;; -		negative-argument
;; .		dired-clean-directory
(defun cpio-dired-clean-directory (keep)
  "Flag numerical backups for deletion.
Spares `cpio-dired-kept-versions' latest versions, and `cpio-kept-old-versions' oldest.
Positive prefix arg KEEP overrides `cpio-dired-kept-versions';
Negative prefix arg KEEP overrides `cpio-kept-old-versions' with KEEP made positive.

To clear the flags on these entries, you can use M-x cpio-dired-flag-backup-entries
with a prefix argument."
  (interactive "P")
  (let ((fname "cpio-dired-clean-directory"))
    (error "%s() is not yet implemented" fname)))
;; 0 .. 9		digit-argument
;; :		Prefix Command
;; <		dired-prev-dirline
(defun cpio-dired-prev-dirline (arg)
  "Goto ARGth previous directory entry line."
  (interactive "p")
  (let ((fname "cpio-dired-prev-dirline"))
    (while (and (< 0 arg)
		(prog2
		    (beginning-of-line)
		    (re-search-backward *cpio-dirline-re* (point-min) t)))
      (setq arg (1- arg)))
    (cpio-dired-move-to-entry-name)))
;; =		dired-diff
(defun cpio-dired-diff (entry &optional switches)
  "Compare entry at point with entry ENTRY using `diff'.
If called interactively, prompt for ENTRY.  If the entry at point
has a backup entry, use that as the default.  If the entry at point
is a backup entry, use its original.  If the mark is active
in Transient Mark mode, use the entry at the mark as the default.
\(That's the mark set by C-SPC, not by Dired's
M-x dired-mark command.)

ENTRY is the first entry given to `diff'.  The entry at point
is the second entry given to `diff'.

With prefix arg, prompt for second argument SWITCHES, which is
the string of command switches for the third argument of `diff'."
  (interactive
   (let* ((current (dired-get-filename t))
	  ;; Get the latest existing backup file or its original.
	  (oldf (if (backup-file-name-p current)
		    (file-name-sans-versions current)
		  (diff-latest-backup-file current)))
	  ;; Get the file at the mark.
	  (file-at-mark (if (and transient-mark-mode mark-active)
			    (save-excursion (goto-char (mark t))
					    (dired-get-filename t t))))
	  (default-file (or file-at-mark
			    (and oldf (file-name-nondirectory oldf))))
	  ;; Use it as default if it's not the same as the current file,
	  ;; and the target dir is current or there is a default file.
	  (default (if (and (not (equal default-file current))
			    (or (equal (dired-dwim-target-directory)
				       (dired-current-directory))
				default-file))
		       default-file))
	  (target-dir (if default
			  (dired-current-directory)
			(dired-dwim-target-directory)))
	  (defaults (dired-dwim-target-defaults (list current) target-dir)))
     (list
      (minibuffer-with-setup-hook
	  (lambda ()
	    (set (make-local-variable 'minibuffer-default-add-function) nil)
	    (setq minibuffer-default defaults))
	(read-file-name
	 (format "Diff %s with%s: " current
		 (if default (format " (default %s)" default) ""))
	 target-dir default t))
      (if current-prefix-arg
	  (read-string "Options for diff: "
		       (if (stringp diff-switches)
			   diff-switches
			 (mapconcat 'identity diff-switches " ")))))))
  (let ((fname "cpio-dired-diff"))
    (error "%s() is not yet implemented" fname)))
;; >		dired-next-dirline
(defun cpio-dired-next-dirline (arg &optional opoint)
  "Goto ARGth next directory entry line."
  (interactive "p")
  (unless opoint (setq opoint (point)))
  (let ((fname "cpio-dired-next-dirline"))
    (while (and (< 0 arg)
		(re-search-forward *cpio-dirline-re* (point-max) t))
      (setq arg (1- arg)))
    (cpio-dired-move-to-entry-name)))
;; ?		dired-summary
(defun cpio-dired-summary ()
  "Summarize basic cpio-dired commands."
  (interactive)
  (let ((fname "cpio-dired-summary"))
    ;>> this should check the key-bindings and use substitute-command-keys if non-standard
    (message
     "d-elete, u-ndelete, x-punge, f-ind, o-ther window, R-ename, C-opy, h-elp")))

;; A		dired-do-search
(defvar *cpio-search-re* nil
  "The most recent RE used to search entries in the affiliated archive.")
(defvar *cpio-search-entries* nil
  "The marked entries for searching in.")
(defvar *cpio-search-entry* nil
  "The most recent entry searched in the affiliated archive.")
(defvar *cpio-search-point* nil
  "The most recent point in the current entry in the affiliated archive.")
(make-variable-buffer-local '*cpio-search-re*)
(make-variable-buffer-local '*cpio-search-entries*)
(make-variable-buffer-local '*cpio-search-entry*)
(make-variable-buffer-local '*cpio-search-point*)
(defun cpio-dired-do-search (regexp)
  "Search through all marked entries for a match for REGEXP.
Stops when a match is found.
To continue searching for next match, use command M-,."
  (interactive "sSearch marked entries (regexp): ")
  (let ((fname "cpio-dired-do-search")
	(entry-names (cpio-dired-get-marked-entries))
	(entry-info)
	(entry-attrs)
	(entry-start)
	(entry-end)
	(entry-buffer))
    (with-current-buffer *cab-parent*
      (setq *cpio-search-re* regexp)
      (setq *cpio-search-entries* entry-names)
      (setq *cpio-search-entry* nil)
      (setq *cpio-search-point* nil))
    (cond ((setq entry-name (catch 'found-one
			      (save-excursion
				(mapc (lambda (en)
					(setq entry-info (assoc en (cpio-catalog)))
					(setq entry-attrs (cpio-entry-attrs en))
					(setq entry-start (cpio-contents-start entry-info))
					(setq entry-end (+ entry-start (cpio-entry-size entry-attrs)))
					(goto-char entry-start)
					(cond ((re-search-foward regexp entry-end t)
					       (with-current-buffer *cab-parent*
						 (setq *cpio-search-entry* en)
						 (setq *cpio-search-point* (- (point) (contents-start))))
					       (with-current-buffer (setq entry-buffer (cpio-dired-find-entry en))
						 (re-search-forward regexp (point-max) t)
						 (throw 'found-one en)
						 )
					       (t nil))))
				      entry-names)))))
	  (t nil))))

(defun cpio-tags-loop-continue ()
  "Continue the search through marked entries in a cpio-dired buffer."
  (interactive)
  (let ((fname "cpio-tags-loop-continue")
	(entry-buffer (get-buffer-create
		       (cpio-contents-buffer-name (with-current-buffer *cab-parent*
						    *cpio-search-entry*))))
	(search-point (with-current-buffer *cab-parent*
			*cpio-search-point*))
	(regex (with-current-buffer *cab-parent*
		 *cpio-search-re*))
	(entry-attrs)
	(contents-size))
    (switch-to-buffer entry-buffer)
    (goto-char search-point)
    (unless (re-search-forward regex (point-max) t)
      (catch 'found-one
	(with-current-buffer *cab-parent*
	  (while (setq *cpio-search-entry* (pop *cpio-search-entries*))
	    (setq entry-attrs (cpio-entry-attrs *cpio-search-entry*))
	    (goto-char (cpio-contents-start *cpio-search-entry*))
	    (cond ((re-search-foward *cpio-search-re* (+ contents-start (cpio-entry-size attrs)))
		   (cpio-dired-find-entry)
		   (goto-char (point-min))
		   (re-search-forward *cpio-search-re (point-max) t)
		   (throw 'found-one))
		  (t nil)))))
      (unless *cpio-search-entries*
	(setq *cpio-search-entry* nil)
	(setq *cpio-search-re* nil)
	(setq *cpio-search-point* nil)))))

(defun cpio-dired-get-marked-entries (&optional arg filter distinguish-one-marked)
  "Return the marked entries' names as a list of strings.
The list is in the same order as the buffer, that is, the car is the
  first marked entry.
Values returned are the entry names as they appear in the archive.
Optional argument ARG, if non-nil, specifies files near
 point instead of marked files.  It usually comes from the prefix
 argument.
  If ARG is an integer, use the next ARG files.
  If ARG is any other non-nil value, return the current file name.
  If no files are marked, and ARG is nil, also return the current file name.
Optional third argument FILTER, if non-nil, is a function to select
  some of the files--those for which (funcall FILTER FILENAME) is non-nil.

If DISTINGUISH-ONE-MARKED is non-nil, then if we find just one marked file,
return (t FILENAME) instead of (FILENAME).
Don't use that together with FILTER."
  (let ((fname "cpio-dired-get-marked-entries")
	(results ()))
    (cond ((and (integerp arg)
		(> arg 0))
	   (save-excursion
	     (while (< 0 arg)
	       (cpio-dired-next-line 1)
	       (push (cpio-dired-get-entry-name) results)
	       (setq arg (1- arg))))
	   (if (and distinguish-one-marked
		    (= 1 (length results)))
	       (list t (car results))
	     (nreverse results)))
	  (arg
	   (cpio-dired-get-entry-name))
	  (t
	   (save-excursion
	     (goto-char (point-min))
	     (forward-line 2)
	     (while (re-search-forward "^\*" (point-max) t)
	       (push (cpio-dired-get-entry-name) results)))
	   (if (and distinguish-one-marked
		    (= 1 (length results)))
	       (list t (car results))
	     (nreverse results))))))
;; B		dired-do-byte-compile
(defun cpio-dired-do-byte-compile (arg)
  "Byte compile marked (or next ARG) Emacs Lisp entries."
  (interactive "p")
  (let ((fname "cpio-dired-do-byte-compile"))
    (error "%s() is not yet implemented" fname)))
;; C		dired-do-copy
(defun cpio-dired-do-copy (arg)
  "Copy all marked (or next ARG) entries, or copy the current entry.
When operating on just the current entry, prompt for the new name.

When operating on multiple or marked entries, prompt for a target
directory, and make the new copies in that directory, with the
same names as the original entries.  The initial suggestion for the
target directory is the Dired buffer's current directory (or, if
\`dired-dwim-target' is non-nil, the current directory of a
neighboring Dired window).

If `dired-copy-preserve-time' is non-nil, this command preserves
the modification time of each old entry in the copy, similar to
the \"-p\" option for the \"cp\" shell command.

This command copies symbolic links by creating new ones, similar
to the \"-d\" option for the \"cp\" shell command."
  (interactive "p")
  (let ((fname "cpio-dired-do-copy"))
    (error "%s() is not yet implemented" fname)))
;; D		dired-do-delete
(defun cpio-dired-do-delete (arg)
  "Delete all marked (or next ARG) entries.
`dired-recursive-deletes' controls whether deletion of
non-empty directories is allowed."
  (interactive "p")
  (let ((fname "cpio-dired-do-delete")
	)
    (error "%s() is not yet implemented" fname)
    ))
;; G		dired-do-chgrp
(defun cpio-dired-do-chgrp (arg)
  "Change the group of the marked (or next ARG) entries.
Type M-n to pull the entry attributes of the entry at point
into the minibuffer."
  (interactive "p")
  (let ((fname "cpio-dired-do-chgrp"))
    (error "%s() is not yet implemented" fname)))
;; H		dired-do-hardlink
(defun cpio-dired-do-hardlink (arg)
  "Add names (hard links) current entry or all marked (or next ARG) entries.
When operating on just the current entry, you specify the new name.
When operating on multiple or marked entries, you specify a directory
and new hard links are made in that directory
with the same names that the entries currently have.  The default
suggested for the target directory depends on the value of
`dired-dwim-target', which see."
  (interactive "p")
  (let ((fname "cpio-dired-do-hardlink"))
    (error "%s() is not yet implemented" fname)))
;; L		dired-do-load
(defun cpio-dired-do-load (arg)
  "Load the marked (or next ARG) Emacs Lisp entries."
  (interactive "p")
  (let ((fname "cpio-dired-do-load"))
    (error "%s() is not yet implemented" fname)))
;; M		dired-do-chmod
(defun cpio-dired-do-chmod (arg)
"Change the mode of the marked (or next ARG) entries.
Symbolic modes like `g+w' are allowed.
Type M-n to pull the entry attributes of the entry at point
into the minibuffer."
  (interactive "p")
  (let ((fname "cpio-dired-do-chmod"))
    (error "%s() is not yet implemented" fname)))
;; O		dired-do-chown
(defun cpio-dired-do-chown (arg)
  "Change the owner of the marked (or next ARG) entries.
Type M-n to pull the entry attributes of the entry at point
into the minibuffer."
  (interactive "p")
  (let ((fname "cpio-dired-do-chown"))
    (error "%s() is not yet implemented" fname)))
;; P		dired-do-print
(defun cpio-dired-do-print (arg)
  "Print the marked (or next ARG) entries.
Uses the shell command coming from variables `lpr-command' and
`lpr-switches' as default."
  (interactive "p")
  (let ((fname "cpio-dired-do-print"))
    (error "%s() is not yet implemented" fname)))
;; Q		dired-do-qeuery-replace-regexp
(defun cpio-dired-do-query-replace-regexp (from to &optional delimited)
  "Do `query-replace-regexp' of FROM with TO, on all marked entries.
Third arg DELIMITED (prefix arg) means replace only word-delimited matches.
If you exit (C-g, RET or q), you can resume the query replace
with the command M-,."
  (interactive
   (let ((common
	  (query-replace-read-args
	   "Query replace regexp in marked files" t t)))
     (list (nth 0 common) (nth 1 common) (nth 2 common))))
  (let ((fname "cpio-dired-do-query-replace-regexp"))
    (error "%s() is not yet implemented" fname)))
;; R		dired-do-rename
(defun cpio-dired-do-rename (arg)
  "Rename current entry or all marked (or next ARG) entries.
When renaming just the current entry, you specify the new name.
When renaming multiple or marked entries, you specify a directory.
This command also renames any buffers that are visiting the entries.
The default suggested for the target directory depends on the value
of `dired-dwim-target', which see."
  (interactive "p")
  (let ((fname "cpio-dired-do-rename"))
    (error "%s() is not yet implemented" fname)))
;; S		dired-do-symlink
(defun cpio-dired-do-symlink (arg)
  "Make symbolic links to current entry or all marked (or next ARG) entries.
When operating on just the current entry, you specify the new name.
When operating on multiple or marked entries, you specify a directory
and new symbolic links are made in that directory
with the same names that the entries currently have.  The default
suggested for the target directory depends on the value of
`dired-dwim-target', which see.

For relative symlinks, use M-x dired-do-relsymlink."
  (interactive "p")
  (let ((fname "cpio-dired-do-symlink"))
    (error "%s() is not yet implemented" fname)))
;; T		dired-do-touch
(defun cpio-dired-do-touch (arg)
  "Change the timestamp of the marked (or next ARG) entries.
This calls touch.
Type M-n to pull the entry attributes of the entry at point
into the minibuffer."
  (interactive "p")
  (let ((fname "cpio-dired-do-touch"))
    (error "%s() is not yet implemented" fname)))
;; * !		dired-unmark-all-marks
;; U		dired-unmark-all-marks
(defun cpio-dired-unmark-all-marks ()
  "Remove all marks from all entries in the Dired buffer."
  (interactive)
  (let ((fname "cpio-dired-unmark-all-marks"))
    ;; (error "%s() is not yet implemented" fname)
    (dired-unmark-all-marks)))
;; X		dired-do-shell-command
(defun cpio-dired-do-shell-command (command &optional arg entry-list)
  "Run a shell command COMMAND on the marked entries.
If no entries are marked or a numeric prefix arg is given,
the next ARG entries are used.  Just C-u means the current entry.
The prompt mentions the entry(s) or the marker, as appropriate.

If there is a `*' in COMMAND, surrounded by whitespace, this runs
COMMAND just once with the entire entry list substituted there.

If there is no `*', but there is a `?' in COMMAND, surrounded by
whitespace, this runs COMMAND on each entry individually with the
entry name substituted for `?'.

Otherwise, this runs COMMAND on each entry individually with the
entry name added at the end of COMMAND (separated by a space).

`*' and `?' when not surrounded by whitespace have no special
significance for `dired-do-shell-command', and are passed through
normally to the shell, but you must confirm first.

If you want to use `*' as a shell wildcard with whitespace around
it, write `*""' in place of just `*'.  This is equivalent to just
`*' in the shell, but avoids Dired's special handling.

If COMMAND ends in `&', `;', or `;&', it is executed in the
background asynchronously, and the output appears in the buffer
`*Async Shell Command*'.  When operating on multiple entries and COMMAND
ends in `&', the shell command is executed on each entry in parallel.
However, when COMMAND ends in `;' or `;&' then commands are executed
in the background on each entry sequentially waiting for each command
to terminate before running the next command.  You can also use
`dired-do-async-shell-command' that automatically adds `&'.

Otherwise, COMMAND is executed synchronously, and the output
appears in the buffer `*Shell Command Output*'.

This feature does not try to redisplay Dired buffers afterward, as
there's no telling what entries COMMAND may have changed.
Type M-x dired-do-redisplay to redisplay the marked entries.

When COMMAND runs, its working directory is the top-level directory
of the Dired buffer, so output entries usually are created there
instead of in a subdir.

In a noninteractive call (from Lisp code), you must specify
the list of entry names explicitly with the ENTRY-LIST argument, which
can be produced by `dired-get-marked-entries', for example."
  (interactive
   (let ((files (dired-get-marked-files t current-prefix-arg)))
     (list
      ;; Want to give feedback whether this file or marked files are used:
      (dired-read-shell-command "! on %s: " current-prefix-arg files)
      current-prefix-arg
      files)))
  (let ((fname "cpio-dired-do-shell-command"))
    (error "%s() is not yet implemented" fname)))
;; Z		dired-do-compress
(defun cpio-dired-do-compress (arg)
  "Compress or uncompress marked (or next ARG) entries."
  (interactive "p")
  (let ((fname "cpio-dired-do-compress"))
    (error "%s() is not yet implemented" fname)))
;; ^		dired-up-directory
(defun cpio-dired-up-directory ()
  "Run Dired on parent directory of current directory.
Find the parent directory either in this buffer or another buffer.
Creates a buffer if necessary.
If OTHER-WINDOW (the optional prefix arg), display the parent
directory in another window."
  (interactive)
  (let ((fname "cpio-dired-up-directory"))
    (error "%s() is not yet implemented" fname)))
;; a		dired-find-alternate-file
(defun cpio-dired-find-alternate-entry ()
  "In Dired, visit this entry or directory instead of the Dired buffer."
  (interactive)
  (let ((fname "cpio-dired-find-alternate-entry"))
    (error "%s() is not yet implemented" fname)))
;; d		dired-flag-file-deletion
(defun cpio-dired-flag-entry-deletion (arg)
  "In Dired, flag the current line's entry for deletion.
If the region is active, flag all entries in the region.
Otherwise, with a prefix arg, flag entries on the next ARG lines.

If on a subdir headerline, flag all its entries except `.' and `..'.
If the region is active in Transient Mark mode, flag all entries
in the active region."
  (interactive "p")
  (let ((fname "cpio-dired-flag-entry-deletion"))
    (error "%s() is not yet implemented" fname)))
;; g		revert-buffer
(defun cpio-revert-buffer ()
  "Replace current buffer text with the text of the visited entry on disk.
This undoes all changes since the entry was visited or saved.
With a prefix argument, offer to revert from latest auto-save entry, if
that is more recent than the visited entry.

This command also implements an interface for special buffers
that contain text which doesn't come from a entry, but reflects
some other data instead (e.g. Dired buffers, `buffer-list'
buffers).  This is done via the variable `revert-buffer-function'.
In these cases, it should reconstruct the buffer contents from the
appropriate data.

When called from Lisp, the first argument is IGNORE-AUTO; only offer
to revert from the auto-save entry when this is nil.  Note that the
sense of this argument is the reverse of the prefix argument, for the
sake of backward compatibility.  IGNORE-AUTO is optional, defaulting
to nil.

Optional second argument NOCONFIRM means don't ask for confirmation
at all.  (The variable `revert-without-query' offers another way to
revert buffers without querying for confirmation.)

Optional third argument PRESERVE-MODES non-nil means don't alter
the entries modes.  Normally we reinitialize them using `normal-mode'.

This function binds `revert-buffer-in-progress-p' non-nil while it operates.

This function calls the function that `revert-buffer-function' specifies
to do the work, with arguments IGNORE-AUTO and NOCONFIRM.
The default function runs the hooks `before-revert-hook' and
`after-revert-hook'."
  (interactive)
  (let ((fname "revert-buffer"))
    (error "%s() is not yet implemented" fname)))
;; h		describe-mode
(defun cpio-describe-mode ()
  "Display documentation of current major mode and minor modes.
A brief summary of the minor modes comes first, followed by the
major mode description.  This is followed by detailed
descriptions of the minor modes, each on a separate page.

For this to work correctly for a minor mode, the mode's indicator
variable (listed in `minor-mode-alist') must also be a function
whose documentation describes the minor mode.

If called from Lisp with a non-nil BUFFER argument, display
documentation for the major and minor modes of that buffer."
  (interactive)
  (let ((fname "describe-mode"))
    (error "%s() is not yet implemented" fname)))
;; i		dired-maybe-insert-subdir
(defun cpio-dired-maybe-insert-subdir ()
  "Insert this subdirectory into the same dired buffer.
If it is already present, just move to it (type M-x dired-do-redisplay to refresh),
  else inserts it at its natural place (as `ls -lR' would have done).
With a prefix arg, you may edit the ls switches used for this listing.
  You can add `R' to the switches to expand the whole tree starting at
  this subdirectory.
This function takes some pains to conform to `ls -lR' output.

Dired remembers switches specified with a prefix arg, so that reverting
the buffer will not reset them.  However, using `dired-undo' to re-insert
or delete subdirectories can bypass this machinery.  Hence, you sometimes
may have to reset some subdirectory switches after a `dired-undo'.
HEREHERE Archives don't hold subdirectories the same way a file system does.
You can reset all subdirectory switches to the default using
M-x dired-reset-subdir-switches.
See Info node `(emacs)Subdir switches' for more details."
  (interactive)
  (let ((fname "cpio-dired-maybe-insert-subdir")
	)
    (error "%s() is not yet implemented" fname)
    ))
;; j		dired-goto-entry
(defun cpio-dired-goto-entry (entry)
  "Go to line describing entry ENTRY in this Dired buffer."
  (interactive
   (prog1				; let push-mark display its message
       (list (expand-file-name
	      (read-file-name "Goto entry: "
			      (dired-current-directory))))
     (push-mark)))
  (let ((fname "cpio-dired-goto-entry"))
    (error "%s() is not yet implemented" fname)))
;; k		dired-do-kill-lines
(defun cpio-dired-do-kill-lines (arg)
  "Kill all marked lines (not the entries).
With a prefix argument, kill that many lines starting with the current line.
\(A negative argument kills backward.)
If you use this command with a prefix argument to kill the line
for a entry that is a directory, which you have inserted in the
Dired buffer as a subdirectory, then it deletes that subdirectory
from the buffer as well.
To kill an entire subdirectory (without killing its line in the
parent directory), go to its directory header line and use this
command with a prefix argument (the value does not matter)."
  (interactive "p")
  (let ((fname "cpio-dired-do-kill-lines"))
    (error "%s() is not yet implemented" fname)))
;; l		dired-do-redisplay
(defun cpio-dired-do-redisplay (arg)
  "Redisplay all marked (or next ARG) entries.
If on a subdir line, redisplay that subdirectory.  In that case,
a prefix arg lets you edit the `ls' switches used for the new listing.

Dired remembers switches specified with a prefix arg, so that reverting
the buffer will not reset them.  However, using `dired-undo' to re-insert
or delete subdirectories can bypass this machinery.  Hence, you sometimes
may have to reset some subdirectory switches after a `dired-undo'.
You can reset all subdirectory switches to the default using
M-x dired-reset-subdir-switches.
See Info node `(emacs)Subdir switches' for more details."
  (interactive "p")
  (let ((fname "cpio-dired-do-redisplay"))
    (error "%s() is not yet implemented" fname)))
;; m		dired-mark
(defun cpio-dired-mark (arg &optional interactive)
  "If the region is active, mark all entries in the region.
Otherwise, with a prefix arg, mark entries on the next ARG lines.

If on a subdir headerline, mark all its entries except `.' and `..'.

Use M-x dired-unmark-all-entries to remove all marks
and M-x dired-unmark on a subdir to remove the marks in
this subdir."
  (interactive "p")
  (let ((fname "cpio-dired-mark")
	(start (if (and interactive (use-region-p))
		   (min (point) (mark))
		 nil))
	(end (if (and interactive (use-region-p))
		 (max (point) (mark))
	       nil))
	(entry-name))
    (cond ((and interactive (use-region-p))
	   (save-excursion
	     (let ((beg (region-beginning))
		   (end (region-end)))
	       (dired-mark-files-in-region
		(progn (goto-char beg) (line-beginning-position))
		(progn (goto-char end) (line-beginning-position))))))
	  (arg
	   (let ((inhibit-read-only t))
	     (dired-repeat-over-lines
	      (prefix-numeric-value arg)
	      (function (lambda () (delete-char 1) (insert cpio-dired-marker-char)))))))))

(defun cpio-dired-mark-this-entry (&optional char)
  "Mark the entry on the current line with the given CHAR.
If CHAR is not given, then use cpio-dired-marker-char.
CONTRACT: You must be allowed to operate on that entry."
  (unless char (setq char cpio-dired-marker-char))
  (let ((fname "cpio-dired-mark-this-entry"))
    (beginning-of-line)
    (delete-char 1)
    (insert (char-to-string char))))
;; n		dired-next-line
;; o		dired-find-file-other-window
(defun cpio-dired-find-entry-other-window ()
  "In Dired, visit this entry or directory in another window."
  (interactive)
  (let ((fname "cpio-dired-find-entry-other-window"))
    (error "%s() is not yet implemented" fname)))
;; p		dired-previous-line
(defun cpio-dired-previous-line (arg)
  "Move up lines then position at entry name.
Optional prefix ARG says how many lines to move; default is one line."
  (interactive "p")
  (let ((fname "cpio-dired-previous-line"))
    (forward-line (- arg))
    (cpio-dired-move-to-entry-name)))
;; q		quit-window
(defun cpio-quit-window (&optional kill window)
  "Quit WINDOW and bury its buffer.
WINDOW must be a live window and defaults to the selected one.
With prefix argument KILL non-nil, kill the buffer instead of
burying it.

According to information stored in WINDOW's `quit-restore' window
parameter either (1) delete WINDOW and its frame, (2) delete
WINDOW, (3) restore the buffer previously displayed in WINDOW,
or (4) make WINDOW display some other buffer than the present
one.  If non-nil, reset `quit-restore' parameter to nil."
  (interactive "P")
  (let ((fname "quit-window")
	(buffer (window-buffer)))
    (cond (kill
	   (kill-buffer buffer))
	  (t
	   (delete-window (selected-window))
	   (bury-buffer buffer)))))
;; s		dired-sort-toggle-or-edit
(defun cpio-dired-sort-toggle-or-edit ()
  "Toggle sorting by date, and refresh the Dired buffer.
With a prefix argument, edit the current listing switches instead."
  (interactive)
  (let ((fname "cpio-dired-sort-toggle-or-edit"))
    (error "%s() is not yet implemented" fname)))
;; t		dired-toggle-marks
(defun cpio-dired-toggle-marks ()
  "Toggle marks: marked entries become unmarked, and vice versa.
Entries marked with other flags (such as `D') are not affected.
`.' and `..' are never toggled.
As always, hidden subdirs are not affected."
  (interactive)
  (let ((fname "cpio-dired-toggle-marks"))
    (error "%s() is not yet implemented" fname)))
;; u		dired-unmark
(defun cpio-dired-unmark (arg &optional interactive)
  "If the region is active, unmark all entries in the region.
Otherwise, with a prefix arg, unmark entries on the next ARG lines.

If looking at a subdir, unmark all its entries except `.' and `..'.
If the region is active in Transient Mark mode, unmark all entries
in the active region."
  ;; HEREHERE This shares a lot of structure sith M-x cpio-dired-mark.
  (interactive (list current-prefix-arg t))
  (let ((fname "cpio-dired-unmark"))
    (cond ((save-excursion (beginning-of-line) (looking-at *cpio-dired-entry-regexp*))
	   (cond ((and interactive (use-region-p))
		  (let ((beg (region-beginning))
			(end (region-end)))
		    (goto-char beg)
		    (while (< (point) end)
		      (cond ((string-match cpio-dired-trivial-filenames (cpio-dired-get-entry-name))
			     t)
			    (t
			     (cpio-dired-mark-this-entry ?\s)))
		      (cpio-dired-next-line 1))))
		 (t
		  (if arg
		      (setq arg (car arg))
		    (setq arg 1))
		  (let ((inhibit-read-only t))
		    (while (< 0 arg)
		      (cpio-dired-mark-this-entry ?\s)
		      (cpio-dired-next-line 1)
		      (setq arg (1- arg)))))))
	  (t nil))
	  (cpio-dired-move-to-entry-name)))
;; v		dired-view-file
(defun cpio-dired-view-entry ()
  "In Dired, examine a entry in view mode, returning to Dired when done.
When entry is a directory, show it in this buffer if it is inserted.
Otherwise, display it in another buffer."
  (interactive)
  (let ((fname "cpio-dired-view-entry"))
    (error "%s() is not yet implemented" fname)))
;; w		dired-copy-filename-as-kill
(defun cpio-dired-copy-entry-name-as-kill (arg)
  "Copy names of marked (or next ARG) entries into the kill ring.
The names are separated by a space.
With a zero prefix arg, use the absolute entry name of each marked entry.
With C-u, use the entry name relative to the Dired buffer's
`default-directory'.  (This still may contain slashes if in a subdirectory.)

If on a subdir headerline, use absolute subdirname instead;
prefix arg and marked entries are ignored in this case.

You can then feed the entry name(s) to other commands with C-y."
  (interactive "p")
  (let ((fname "cpio-dired-copy-entry-name-as-kill"))
    (error "%s() is not yet implemented" fname)))
;; x		dired-do-flagged-delete
(defun cpio-dired-do-flagged-delete (nomessage)
  "In Dired, delete the entries flagged for deletion.
If NOMESSAGE is non-nil, we don't display any message
if there are no flagged entries.
`dired-recursive-deletes' controls whether deletion of
non-empty directories is allowed."
  (interactive)
  (let ((fname "cpio-dired-do-flagged-delete"))
    (error "%s() is not yet implemented" fname)))
;; y		dired-show-file-type
(defun cpio-dired-show-entry-type (entry &optional deref-symlinks)
  "Print the type of ENTRY, according to the `entry' command.
If you give a prefix to this command, and ENTRY is a symbolic
link, then the type of the entry linked to by ENTRY is printed
instead."
  (interactive (list (dired-get-filename t) current-prefix-arg))
  (let ((fname "cpio-dired-show-entry-type"))
    (error "%s() is not yet implemented" fname)))
;; ~		dired-flag-backup-entries
(defun cpio-dired-flag-backup-entries (arg)
  "Flag all backup entries (names ending with `~') for deletion.
With prefix argument, unmark or unflag these entries."
  (interactive "p")
  (let ((fname "cpio-dired-flag-backup-entries"))
    (error "%s() is not yet implemented" fname)))
;; DEL		dired-unmark-backward
(defun cpio-dired-unmark-backward (&optional arg)
  "In a cpio UI buffer, move up lines and remove marks or deletion flags there.
Optional prefix ARG says how many lines to unmark/unflag; default
is one line.
If the region is active in Transient Mark mode, unmark all entries
in the active region."
  (interactive "p")
  (let ((fname "cpio-dired-unmark-backward"))
    (error "%s() is not yet implemented" fname)))
;; S-SPC		scroll-down-command
(defun cpio-scroll-down-command (arg)
  "Scroll text of selected window down ARG lines; or near full screen if no ARG.
If `scroll-error-top-bottom' is non-nil and `scroll-down' cannot
scroll window further, move cursor to the top line.
When point is already on that position, then signal an error.
A near full screen is `next-screen-context-lines' less than a full screen.
Negative ARG means scroll upward.
If ARG is the atom `-', scroll upward by nearly full screen."
  (interactive "p")
  (let ((fname "scroll-down-command"))
    (error "%s() is not yet implemented" fname)))
;; <follow-link>	mouse-face
;; <mouse-2>	dired-mouse-find-file-other-window
(defun cpio-dired-mouse-find-entry-other-window ()
  "In a cpio UI window, visit the entry or directory name you click on."
  (interactive)
  (let ((fname "cpio-dired-mouse-find-entry-other-window"))
    (error "%s() is not yet implemented" fname)))
;; <remap>		Prefix Command
;; 
;; C-t C-t		image-dired-dired-toggle-marked-thumbs
(defun cpio-image-dired-dired-toggle-marked-thumbs (arg)
  "Toggle thumbnails in front of entry names in the dired buffer.
If no marked entry could be found, insert or hide thumbnails on the
current line.  ARG, if non-nil, specifies the entries to use instead
of the marked entries.  If ARG is an integer, use the next ARG (or
previous -ARG, if ARG<0) entries."
  (interactive "p")
  (let ((fname "image-dired-dired-toggle-marked-thumbs"))
    (error "%s() is not yet implemented" fname)))
;; C-t .		image-dired-display-thumb
(defun cpio-image-dired-display-thumb (arg)
  "Shorthand for `image-dired-display-thumbs' with prefix argument."
  (interactive "p")
  (let ((fname "image-dired-display-thumb"))
    (error "%s() is not yet implemented" fname)))
;; C-t a		image-dired-display-thumbs-append
(defun cpio-image-dired-display-thumbs-append ()
  "Append thumbnails to `image-dired-thumbnail-buffer'."
  (interactive)
  (let ((fname "image-dired-display-thumbs-append"))
    (error "%s() is not yet implemented" fname)))
;; C-t c		image-dired-dired-comment-entries
(defun cpio-image-dired-dired-comment-entries ()
  "Add comment to current or marked entries in dired."
  (interactive)
  (let ((fname "image-dired-dired-comment-entries"))
    (error "%s() is not yet implemented" fname)))
;; C-t d		image-dired-display-thumbs
(defun cpio-image-dired-display-thumbs (&optional arg append do-not-pop)
  "Display thumbnails of all marked entries, in `image-dired-thumbnail-buffer'.
If a thumbnail image does not exist for a entry, it is created on the
fly.  With prefix argument ARG, display only thumbnail for entry at
point (this is useful if you have marked some entries but want to show
another one).

Recommended usage is to split the current frame horizontally so that
you have the dired buffer in the left window and the
`image-dired-thumbnail-buffer' buffer in the right window.

With optional argument APPEND, append thumbnail to thumbnail buffer
instead of erasing it first.

Optional argument DO-NOT-POP controls if `pop-to-buffer' should be
used or not.  If non-nil, use `display-buffer' instead of
`pop-to-buffer'.  This is used from functions like
`image-dired-next-line-and-display' and
`image-dired-previous-line-and-display' where we do not want the
thumbnail buffer to be selected."
  (interactive "P")
  (let ((fname "image-dired-display-thumbs"))
    (error "%s() is not yet implemented" fname)))
;; C-t e		image-dired-dired-edit-comment-and-tags
(defun cpio-image-dired-dired-edit-comment-and-tags ()
  "Edit comment and tags of current or marked image entries.
Edit comment and tags for all marked image entries in an
easy-to-use form."
  (interactive)
  (let ((fname "image-dired-dired-edit-comment-and-tags"))
    (error "%s() is not yet implemented" fname)))
;; C-t f		image-dired-mark-tagged-entries
(defun cpio-image-dired-mark-tagged-entries ()
  ;; M-x image-dired-mark-tagged-entries is not defined:
  ;;     image-dired-mark-tagged-entries is an alias for `image-dired-mark-tagged-entries',
  ;;     which is not defined.  Please make a bug report.
  ;; What should I do with this?
  "Use regexp to mark entries with matching tag.
A `tag' is a keyword, a piece of meta data, associated with an
image entry and stored in image-dired's database entry.  This command
lets you input a regexp and this will be matched against all tags
on all image entries in the database entry.  The entries that have a
matching tag will be marked in the dired buffer."
  (interactive)
  (let ((fname "image-dired-mark-tagged-entries"))
    (error "%s() is not yet implemented" fname)))
;; C-t i		image-dired-dired-display-image
(defun cpio-image-dired-dired-display-image (&optional arg)
  "Display current image entry.
See documentation for `image-dired-display-image' for more information.
With prefix argument ARG, display image in its original size."
  (interactive "p")
  (let ((fname "image-dired-dired-display-image"))
    (error "%s() is not yet implemented" fname)))
;; C-t j		image-dired-jump-thumbnail-buffer
(defun cpio-image-dired-jump-thumbnail-buffer ()
  "Jump to thumbnail buffer."
  (interactive)
  (let ((fname "image-dired-jump-thumbnail-buffer"))
    (error "%s() is not yet implemented" fname)))
;; C-t r		image-dired-delete-tag
(defun cpio-image-dired-delete-tag (arg)
  "Remove tag for selected entry(s).
With prefix argument ARG, remove tag from entry at point."
  (interactive "P")
  (let ((fname "image-dired-delete-tag"))
    (error "%s() is not yet implemented" fname)))
;; C-t t		image-dired-tag-entries
(defun cpio-image-dired-tag-entries (arg)
  "Tag marked entry(s) in dired.  With prefix ARG, tag entry at point."
  (interactive "P")
  (let ((fname "image-dired-tag-entries"))
    (error "%s() is not yet implemented" fname)))
;; C-t x		image-dired-dired-display-external
(defun cpio-image-dired-dired-display-external ()
  "Display entry at point using an external viewer."
  (interactive)
  (let ((fname "image-dired-dired-display-external"))
    (error "%s() is not yet implemented" fname)))
;; 
;; C-M-d		dired-tree-down
(defun cpio-dired-tree-down ()
  "Go down in the dired tree."
  (interactive)
  (let ((fname "cpio-dired-tree-down"))
    (error "%s() is not yet implemented" fname)))
;; C-M-n		dired-next-subdir
(defun cpio-dired-next-subdir ()
  "Go to next subdirectory, regardless of level."
  (interactive)
  (let ((fname "cpio-dired-next-subdir"))
    (error "%s() is not yet implemented" fname)))
;; C-M-p		dired-prev-subdir
(defun cpio-dired-prev-subdir ()
  "Go to previous subdirectory, regardless of level.
When called interactively and not on a subdir line, go to this subdir's line."
  (interactive)
  (let ((fname "cpio-dired-prev-subdir"))
    (error "%s() is not yet implemented" fname)))
;; C-M-u		dired-tree-up
(defun cpio-dired-tree-up (arg)
  "Go up ARG levels in the dired tree."
  (interactive)
  (let ((fname "cpio-dired-tree-up"))
    (error "%s() is not yet implemented" fname)))
;; M-$		dired-hide-all
(defun cpio-dired-hide-all ()
  "Hide all subdirectories, leaving only their header lines.
If there is already something hidden, make everything visible again.
Use M-x dired-hide-subdir to (un)hide a particular subdirectory."
  (interactive)
  (let ((fname "cpio-dired-hide-all"))
    (error "%s() is not yet implemented" fname)))
;; M-s		Prefix Command
;; M-{		dired-prev-marked-file
(defun cpio-dired-prev-marked-entry (arg wrap)
  "Move to the previous marked entry.
If WRAP is non-nil, wrap around to the end of the buffer if we
reach the beginning of the buffer."
  (interactive "p\np")
  (let ((fname "cpio-dired-prev-marked-entry"))
    (error "%s() is not yet implemented" fname)))
;; M-}		dired-next-marked-file
(defun cpio-dired-next-marked-entry (wrap)
  "Move to the previous marked entry.
If WRAP is non-nil, wrap around to the end of the buffer if we
reach the beginning of the buffer."
  (let ((fname "cpio-dired-next-marked-entry"))
    (error "%s() is not yet implemented" fname)))
;; M-DEL		dired-unmark-all-entries
(defun cpio-dired-unmark-all-entries ()
  "Move to the next marked entry.
If WRAP is non-nil, wrap around to the beginning of the buffer if
we reach the end."
  (interactive)
  (let ((fname "cpio-dired-unmark-all-entries"))
    (error "%s() is not yet implemented" fname)))
;; 
;; M-s a		Prefix Command
;; M-s f		Prefix Command
;; 
;; % &		dired-flag-garbage-entries
(defun cpio-dired-flag-garbage-entries ()
  "Flag for deletion all entries that match `dired-garbage-entries-regexp'."
  (interactive)
  (let ((fname "cpio-dired-flag-garbage-entries"))
    (error "%s() is not yet implemented" fname)))
;; % C		dired-do-copy-regexp
(defun cpio-dired-do-copy-regexp (regexp newname &optional arg whole-name)
  "Copy selected entries whose names match REGEXP to NEWNAME.
See function `cpio-dired-do-rename-regexp' for more info."
  (interactive (cpio-dired-mark-read-regexp "Copy"))
  (let ((fname "cpio-dired-do-copy-regexp"))
    (error "%s() is not yet implemented" fname)))
;; % H		dired-do-hardlink-regexp
(defun cpio-dired-do-hardlink-regexp (regexp newname &optional arg whole-name)
  "Hardlink selected entries whose names match REGEXP to NEWNAME.
See function `dired-do-rename-regexp' for more info."
  (interactive (cpio-dired-mark-read-regexp "HardLink"))
  (let ((fname "cpio-dired-do-hardlink-regexp"))
    (error "%s() is not yet implemented" fname)))
;; % R		dired-do-rename-regexp
(defun cpio-dired-do-rename-regexp (regexp newname &optional whole-name)
  "Rename selected entries whose names match REGEXP to NEWNAME.

With non-zero prefix argument ARG, the command operates on the next ARG
entries.  Otherwise, it operates on all the marked entries, or the current
entry if none are marked.

As each match is found, the user must type a character saying
  what to do with it.  For directions, type C-h at that time.
NEWNAME may contain \<n> or \& as in `query-replace-regexp'.
REGEXP defaults to the last regexp used.

With a zero prefix arg, renaming by regexp affects the absolute entry name.
Normally, only the non-directory part of the entry name is used and changed."
  (interactive (cpio-dired-mark-read-regexp "Rename"))
  (let ((fname "cpio-dired-do-rename-regexp"))
    (error "%s() is not yet implemented" fname)))
;; % S		dired-do-symlink-regexp
(defun cpio-dired-do-symlink-regexp (regexp newname &optional arg whole-name)
  "Symlink selected entries whose names match REGEXP to NEWNAME.
See function `dired-do-rename-regexp' for more info."
  (interactive (cpio-dired-mark-read-regexp "SymLink"))
  (let ((fname "cpio-dired-do-symlink-regexp"))
    (error "%s() is not yet implemented" fname)))
;; % d		dired-flag-entries-regexp
(defun cpio-dired-flag-entries-regexp (regexp)
  ;;     dired-flag-entries-regexp is an alias for `dired-flag-entries-regexp',
  ;;     which is not defined.  Please make a bug report.
  "In Dired, flag all entries containing the specified REGEXP for deletion.
The match is against the non-directory part of the entry name.  Use `^'
  and `$' to anchor matches.  Exclude subdirs by hiding them.
`.' and `..' are never flagged."
  (interactive (cpio-dired-mark-read-regexp "SymLink"))
  (let ((fname "cpio-dired-flag-entries-regexp"))
    (error "%s() is not yet implemented" fname)))

;; % g		dired-mark-entries-containing-regexp
(defun cpio-dired-mark-entries-containing-regexp (regexp)
  ;;     dired-mark-entries-containing-regexp is an alias for `dired-mark-entries-containing-regexp',
  ;;     which is not defined.  Please make a bug report.
  "Mark all entries with contents containing REGEXP for use in later commands.
A prefix argument means to unmark them instead.
`.' and `..' are never marked."
  (interactive
   (list (read-regexp (concat (if current-prefix-arg "Unmark" "Mark")
                              " files containing (regexp): ")
                      nil 'dired-regexp-history)
	 (if current-prefix-arg ?\040)))
  (let ((fname "cpio-dired-mark-entries-containing-regexp"))
    (error "%s() is not yet implemented" fname)))
;; % l		dired-downcase
(defun cpio-dired-downcase (arg)
  "Rename all marked (or next ARG) entries to lower case."
  (interactive "p")
  (let ((fname "cpio-dired-downcase"))
    (error "%s() is not yet implemented" fname)))
;; % m		dired-mark-entries-regexp
;; * %		dired-mark-entries-regexp
(defun cpio-dired-mark-entries-regexp (regexp)
  ;;     dired-mark-entries-regexp is an alias for `dired-mark-entries-regexp',
  ;;     which is not defined.  Please make a bug report.
  "Mark all entries matching REGEXP for use in later commands.
A prefix argument means to unmark them instead.
`.' and `..' are never marked.

REGEXP is an Emacs regexp, not a shell wildcard.  Thus, use `\.o$' for
object entries--just `.o' will mark more than you might think."
  (interactive (list (read-regexp (concat (if current-prefix-arg "Unmark" "Mark")
					  " files (regexp): ")
				  nil 'dired-regexp-history)))
  (let ((fname "cpio-dired-mark-entries-regexp")
	(entry-name))
    ;; (error "%s() is not yet implemented" fname)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward *cpio-dired-entry-regexp* (point-max) t)
	(if (string-match regexp (cpio-dired-get-entry-name))
	    (cpio-dired-mark 1))))))

;; % r		dired-do-rename-regexp
(defun cpio-dired-do-rename-regexp (regexp newname &optional arg whole-name)
  "Rename selected entries whose names match REGEXP to NEWNAME.

With non-zero prefix argument ARG, the command operates on the next ARG
entries.  Otherwise, it operates on all the marked entries, or the current
entry if none are marked.

As each match is found, the user must type a character saying
  what to do with it.  For directions, type C-h at that time.
NEWNAME may contain \<n> or \& as in `query-replace-regexp'.
REGEXP defaults to the last regexp used.

With a zero prefix arg, renaming by regexp affects the absolute entry name.
Normally, only the non-directory part of the entry name is used and changed."
  (interactive (cpio-dired-mark-read-regexp "Rename"))
  (let ((fname "cpio-dired-do-rename-regexp"))
    (error "%s() is not yet implemented" fname)))
;; % u		dired-upcase
(defun cpio-dired-upcase (arg)
  "Rename all marked (or next ARG) entries to upper case."
  (interactive)
  (let ((fname "cpio-dired-upcase"))
    (error "%s() is not yet implemented" fname)))
;; 
;; * C-n		dired-next-marked-file
(defun cpio-dired-next-marked-entry (arg &optional wrap opoint)
  "Move to the next marked entry.
If WRAP is non-nil, wrap around to the beginning of the buffer if
we reach the end."
  (interactive "p\np")
  (let ((fname "cpio-dired-next-marked-entry"))
    (error "%s() is not yet implemented" fname)))
;; * C-p		dired-prev-marked-file
(defun cpio-dired-prev-marked-entry (arg &opitonal wrap)
  "Move to the previous marked entry.
If WRAP is non-nil, wrap around to the end of the buffer if we
reach the beginning of the buffer."
  (interactive "p\np")
  (let ((fname "cpio-dired-prev-marked-entry"))
    (error "%s() is not yet implemented" fname)))
;; * *		dired-mark-executables
(defun cpio-dired-mark-executables (arg)
  "Mark all executable entries.
With prefix argument, unmark or unflag all those entries."
  (interactive "P")
  (let ((fname "cpio-dired-mark-executables"))
    (error "%s() is not yet implemented" fname)))
;; * /		dired-mark-directories
(defun cpio-dired-mark-directories ()
  "Mark all directory entry lines except `.' and `..'.
With prefix argument, unmark or unflag all those entries."
  (interactive)
  (let ((fname "cpio-dired-mark-directories"))
    (error "%s() is not yet implemented" fname)))
;; * ?		dired-unmark-all-entries
(defun cpio-dired-unmark-all-entries (mark &optional arg)
  "Remove a specific mark (or any mark) from every entry.
After this command, type the mark character to remove,
or type RET to remove all marks.
With prefix arg, query for each marked entry.
Type C-h at that time for help."
  (interactive "cRemove marks (RET means all): \nP")
  (let ((fname "cpio-dired-unmark-all-entries"))
    (error "%s() is not yet implemented" fname)))
;; * @		dired-mark-symlinks
(defun cpio-dired-mark-symlinks (unflag-p)
  "Mark all symbolic links.
With prefix argument, unmark or unflag all those entries."
  (interactive "P")
  (let ((fname "cpio-dired-mark-symlinks"))
    (error "%s() is not yet implemented" fname)))
;; * c		dired-change-marks
(defun cpio-dired-change-marks (old new)
  "Change all OLD marks to NEW marks.
OLD and NEW are both characters used to mark entries."
  (interactive
   (let* ((cursor-in-echo-area t)
	  (old (progn (message "Change (old mark): ") (read-char)))
	  (new (progn (message  "Change %c marks to (new mark): " old)
		      (read-char))))
     (list old new)))
  (let ((fname "cpio-dired-change-marks"))
    (error "%s() is not yet implemented" fname)))
;; * m		dired-mark
;; Defined above.
;; * s		dired-mark-subdir-entries
(defun cpio-dired-mark-subdir-entries ()
  "Mark all entries except `.' and `..' in current subdirectory.
If the Dired buffer shows multiple directories, this command
marks the entries listed in the subdirectory that point is in."
  (interactive)
  (let ((fname "cpio-dired-mark-subdir-entries"))
    (error "%s() is not yet implemented" fname)))
;; * t		dired-toggle-marks
(defun cpio-dired-toggle-marks ()
  "Toggle marks: marked entries become unmarked, and vice versa.
Entries marked with other flags (such as `D') are not affected.
`.' and `..' are never toggled.
As always, hidden subdirs are not affected."
  (interactive)
  (let ((fname "cpio-dired-toggle-marks"))
    (error "%s() is not yet implemented" fname)))
;; * u		dired-unmark
(defun cpio-dired-unmark (arg &optional interactive)
  "If the region is active, unmark all entries in the region.
Otherwise, with a prefix arg, unmark entries on the next ARG lines.

If looking at a subdir, unmark all its entries except `.' and `..'.
If the region is active in Transient Mark mode, unmark all entries
in the active region."
  (interactive (list current-prefix-arg t))
  (let ((fname "cpio-dired-unmark"))
    (error "%s() is not yet implemented" fname)))
;; * DEL		dired-unmark-backward
(defun cpio-dired-unmark-backward (arg)
  "In Dired, move up lines and remove marks or deletion flags there.
Optional prefix ARG says how many lines to unmark/unflag; default
is one line.
If the region is active in Transient Mark mode, unmark all entries
in the active region."
  (interactive "p")
  (let ((fname "cpio-dired-unmark-backward"))
    (error "%s() is not yet implemented" fname)))
;; 
;; : d		epa-dired-do-decrypt
(defun cpio-epa-dired-do-decrypt ()
  "Decrypt marked entries."
  (interactive)
  (let ((fname "epa-dired-do-decrypt"))
    (error "%s() is not yet implemented" fname)))
;; : e		epa-dired-do-encrypt
(defun cpio-epa-dired-do-encrypt ()
  "Encrypt marked entries."
  (interactive)
  (let ((fname "epa-dired-do-encrypt"))
    (error "%s() is not yet implemented" fname)))
;; : s		epa-dired-do-sign
(defun cpio-epa-dired-do-sign ()
  "Sign marked entries."
  (interactive)
  (let ((fname "epa-dired-do-sign"))
    (error "%s() is not yet implemented" fname)))
;; : v		epa-dired-do-verify
(defun cpio-epa-dired-do-verify ()
  "Verify marked entries."
  (interactive)
  (let ((fname "epa-dired-do-verify"))
    (error "%s() is not yet implemented" fname)))
;; 
;; <remap> <advertised-undo>	dired-undo
(defun cpio-dired-undo ()
  "This doesn't recover lost entries, it just undoes changes in the buffer itself.
You can use it to recover marks, killed lines or subdirs."
  (interactive)
  (let ((fname "cpio-dired-undo"))
    (error "%s() is not yet implemented" fname)))
;; <remap> <next-line>		dired-next-line
;; <remap> <previous-line>		dired-previous-line
;; <remap> <read-only-mode>	dired-toggle-read-only
(defun cpio-dired-toggle-read-only ()
  ;; HEREHERE Figure out very precisely what this means for M-x cpio-mode.
  "Edit Dired buffer with Wdired, or make it read-only.
If the current buffer can be edited with Wdired, (i.e. the major
mode is `dired-mode'), call `wdired-change-to-wdired-mode'.
Otherwise, toggle `read-only-mode'."
  (interactive)
  (let ((fname "cpio-dired-toggle-read-only"))
    (error "%s() is not yet implemented" fname)))
;; <remap> <toggle-read-only>	dired-toggle-read-only
(defun cpio-dired-toggle-read-only ()
  ;; HEREHERE Figure out very precisely what this means for M-x cpio-mode.
  "Edit Dired buffer with Wdired, or make it read-only.
If the current buffer can be edited with Wdired, (i.e. the major
mode is `dired-mode'), call `wdired-change-to-wdired-mode'.
Otherwise, toggle `read-only-mode'."
  (interactive)
  (let ((fname "cpio-dired-toggle-read-only"))
    (error "%s() is not yet implemented" fname)))
;; <remap> <undo>			dired-undo
(defun cpio-dired-undo ()
  "Search for a string using Isearch only in entry names in the Dired buffer.
You can use it to recover marks, killed lines or subdirs."
  (interactive)
  (let ((fname "cpio-dired-undo"))
    (error "%s() is not yet implemented" fname)))
;; 
;; M-s f C-s	dired-isearch-filenames
(defun cpio-dired-isearch-entry-names ()
  "Search for a string using Isearch only in entry names in the Dired buffer."
  (interactive)
  (let ((fname "cpio-dired-isearch-entry-names"))
    (error "%s() is not yet implemented" fname)))
;; 
;; M-s a C-s	dired-do-isearch
(defun cpio-dired-do-isearch ()
  "Search for a string through all marked entries using Isearch."
  (interactive)
  (let ((fname "cpio-dired-do-isearch"))
    (error "%s() is not yet implemented" fname)))
;; M-s a ESC	Prefix Command
;; 
;; M-s f C-M-s	dired-isearch-filenames-regexp
(defun cpio-dired-isearch-entry-names-regexp ()
  "Search for a regexp using Isearch only in entry names in the cpio-dired buffer."
  (interactive)
  (let ((fname "cpio-dired-isearch-entry-names-regexp"))
    (error "%s() is not yet implemented" fname)))
;; 
;; M-s a C-M-s	dired-do-isearch-regexp
(defun cpio-dired-do-isearch-regexp ()
  "Search for a regexp through all marked entries using Isearch."
  (interactive)
  (let ((fname "cpio-dired-do-isearch-regexp"))
    (error "%s() is not yet implemented" fname)))

(defun cpio-dired-view-archive ()
  "Switch to the buffer holding the cpio archive for this cpio-dired style buffer."
  (interactive)
  (let ((fname "cpio-dired-view-archive"))
    (switch-to-buffer *cab-parent*)))


(defun cpio-dired-extract-all ()
  "Extract all the entries in the current CPIO arhcive."
  (interactive)
  (let ((fname "cpio-dired-extract-all")
	)
    ;; (error "%s() is not yet implemented" fname)
    (unless (string-equal mode-name "cpio-dired")
      (error "%s() only makes sense in a cpio-dired buffer." fname))
    (cpio-extract-all)))

(defun cpio-dired-extract-entries (arg)
  "Extract the marked entries in the current CPIO dired buffer."
  (interactive "p")
  (let ((fname "cpio-dired-extract-entries")
	(files (or (cpio-dired-get-marked-entries)
		   (list (cpio-dired-get-entry-name))))
	)
    ;; (error "%s() is not yet implemented" fname)
    (unless (string-equal mode-name "cpio-dired")
      (error "%s() only makes sense in a cpio-dired buffer." fname))
    (mapc 'cpio-extract-entry files)))

(defun cpio-dired-get-marked-entries ()
  "Return a list of the marked entries in the current cpio-dired buffer."
  (let ((fname "cpio-dired-get-marked-entries")
	(results ())
	(regexp (cpio-dired-marker-regexp)))
    (unless (string-equal mode-name "cpio-dired")
      (error "%s() only makes sense in a cpio-dired buffer." fname))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward regexp (point-max) t)
	(push (cpio-dired-get-entry-name) results)))
    (if results
	results
      (list (cpio-dired-get-entry-name)))))

(defun cpio-dired-marker-regexp ()
  "Return a regular expression to match a marked entry."
  (concat "^" (regexp-quote (char-to-string cpio-dired-marker-char))))

;; 
;; Mode definition (IF APPROPRIATE)
;; 
(defvar *cpio-dired-have-made-keymap* nil)
(define-derived-mode cpio-dired-mode fundamental-mode "cpio-dired"
  "Mode for editing cpio archives in the style of dired."
  :group 'cpio
  ;; (add-hook  'kill-buffer-hook (lambda () (kill-buffer *cab-parent*)) "append" "local"))
  (goto-char (point-min))
  (cond ((re-search-forward *cpio-dired-entry-regexp* (point-max) t)
	 (cpio-dired-move-to-entry-name))
	(t t)))

(defun cpio-dired-make-keymap ()
  "Make the keymap for the cpio-dired UI."
  (let ((fname "cpio-dired-make-keymap")
	(keymap (make-keymap)))
    (setq cpio-dired-mode-map keymap)
    (unless *cpio-dired-have-made-keymap*
      (define-key cpio-dired-mode-map "\C-c\C-c" 'cpio-dired-view-archive) ;✓
      ;; e .. f		dired-find-file
      ;; 
      ;; RET		dired-find-file
      (define-key cpio-dired-mode-map "e" 'cpio-dired-find-entry) ;✓
      (define-key cpio-dired-mode-map "f" 'cpio-dired-find-entry) ;✓
      (define-key cpio-dired-mode-map "\C-j" 'cpio-dired-find-entry) ;✓
      ;; C-o		dired-display-file
      (define-key cpio-dired-mode-map "\C-o" 'cpio-dired-display-entry) ;✓
      ;; C-t		Prefix Command
      ;; ESC		Prefix Command
      ;; SPC		dired-next-line
      (define-key cpio-dired-mode-map " " 'cpio-dired-next-line) ;✓
      ;; !		dired-do-shell-command
      ;; (define-key cpio-dired-mode-map "!" 'cpio-dired-do-shell-command) ;×
      ;; #		dired-flag-auto-save-files
      (define-key cpio-dired-mode-map "#" 'cpio-dired-flag-auto-save-entries)
      ;; $		dired-hide-subdir
      (define-key cpio-dired-mode-map "$" 'cpio-dired-hide-subdir) ;?
      ;; %		Prefix Command
      (define-key cpio-dired-mode-map "%" nil)
      ;; &		dired-do-async-shell-command
      (define-key cpio-dired-mode-map "&" 'cpio-dired-do-async-shell-command) ;×
      ;; (		dired-hide-details-mode
      (define-key cpio-dired-mode-map "(" 'cpio-dired-hide-details-mode) ;?
      ;; *		Prefix Command
      ;; (define-key cpio-dired-mode-map "+" nil) ;×
      ;; +		dired-create-directory
      (define-key cpio-dired-mode-map "+" 'cpio-dired-create-directory)
      ;; -		negative-argument
      ;; .		dired-clean-directory
      (define-key cpio-dired-mode-map "." 'cpio-dired-clean-directory)
      ;; 0 .. 9		digit-argument
      ;; :		Prefix Command
      (define-key cpio-dired-mode-map ":" nil)
      ;; <		dired-prev-dirline
      (define-key cpio-dired-mode-map "<" 'cpio-dired-prev-dirline) ;✓
      ;; =		dired-diff
      (define-key cpio-dired-mode-map "=" 'cpio-dired-diff) ;×
      ;; >		dired-next-dirline
      (define-key cpio-dired-mode-map ">" 'cpio-dired-next-dirline) ;✓
      ;; ?		dired-summary
      (define-key cpio-dired-mode-map "?" 'cpio-dired-summary) ;✓
      ;; A		dired-do-search
      (define-key cpio-dired-mode-map "A" 'cpio-dired-do-search)
      (define-key cpio-dired-mode-map "\M-," 'cpio-tags-loop-continue)
      ;; B		dired-do-byte-compile
      (define-key cpio-dired-mode-map "B" 'cpio-dired-do-byte-compile)
      ;; C		dired-do-copy
      (define-key cpio-dired-mode-map "C" 'cpio-dired-do-copy)
      ;; D		dired-do-delete
      (define-key cpio-dired-mode-map "D" 'cpio-dired-do-delete)
      ;; G		dired-do-chgrp
      (define-key cpio-dired-mode-map "G" 'cpio-dired-do-chgrp)
      ;; H		dired-do-hardlink
      (define-key cpio-dired-mode-map "H" 'cpio-dired-do-hardlink)
      ;; L		dired-do-load
      (define-key cpio-dired-mode-map "L" 'cpio-dired-do-load)
      ;; M		dired-do-chmod
      (define-key cpio-dired-mode-map "M" 'cpio-dired-do-chmod)
      ;; O		dired-do-chown
      (define-key cpio-dired-mode-map "O" 'cpio-dired-do-chown)
      ;; P		dired-do-print
      (define-key cpio-dired-mode-map "P" 'cpio-dired-do-print)
      ;; Q		dired-do-query-replace-regexp
      (define-key cpio-dired-mode-map "Q" 'cpio-dired-do-query-replace-regexp)
      ;; R		dired-do-rename
      (define-key cpio-dired-mode-map "R" 'cpio-dired-do-rename)
      ;; S		dired-do-symlink
      (define-key cpio-dired-mode-map "S" 'cpio-dired-do-symlink)
      ;; T		dired-do-touch
      (define-key cpio-dired-mode-map "T" 'cpio-dired-do-touch)
      ;; U		dired-unmark-all-marks
      (define-key cpio-dired-mode-map "U" 'cpio-dired-unmark-all-marks)
      ;;;; ;; X		dired-do-shell-command
      ;;;; (define-key cpio-dired-mode-map "X" 'cpio-dired-do-shell-command)
      ;; X	prefix command
      (define-key cpio-dired-mode-map "X" nil)
      ;; Xa
      (define-key cpio-dired-mode-map "Xa" 'cpio-dired-extract-all)
      ;; Xm
      (define-key cpio-dired-mode-map "Xm" 'cpio-dired-extract-entries)
      ;; Z		dired-do-compress
      (define-key cpio-dired-mode-map "Z" 'cpio-dired-do-compress)
      ;; ^		dired-up-directory
      (define-key cpio-dired-mode-map "^" 'cpio-dired-up-directory)
      ;; a		dired-find-alternate-file
      (define-key cpio-dired-mode-map "a" 'cpio-dired-find-alternate-entry)
      ;; d		dired-flag-file-deletion
      (define-key cpio-dired-mode-map "d" 'cpio-dired-flag-entry-deletion)
      ;; g		revert-buffer
      (define-key cpio-dired-mode-map "g" 'cpio-revert-buffer)
      ;; h		describe-mode
      (define-key cpio-dired-mode-map "h" 'cpio-describe-mode)
      ;; i		dired-maybe-insert-subdir
      (define-key cpio-dired-mode-map "i" 'cpio-dired-maybe-insert-subdir)
      ;; j		dired-goto-file
      (define-key cpio-dired-mode-map "j" 'cpio-dired-goto-entry)
      ;; k		dired-do-kill-lines
      (define-key cpio-dired-mode-map "k" 'cpio-dired-do-kill-lines)
      ;; l		dired-do-redisplay
      (define-key cpio-dired-mode-map "l" 'cpio-dired-do-redisplay)
      ;; m		dired-mark
      (define-key cpio-dired-mode-map "m" 'cpio-dired-mark) ;✓
      ;; n		dired-next-line
      (define-key cpio-dired-mode-map "n" 'cpio-dired-next-line)
      (define-key cpio-dired-mode-map "\C-n" 'cpio-dired-next-line)
      ;; o		dired-find-file-other-window
      (define-key cpio-dired-mode-map "o" 'cpio-dired-find-entry-other-window)
      ;; p		dired-previous-line
      (define-key cpio-dired-mode-map "p" 'cpio-dired-previous-line)
      (define-key cpio-dired-mode-map "\C-p" 'cpio-dired-previous-line)
      ;; q		quit-window
      (define-key cpio-dired-mode-map "q" 'cpio-quit-window)
      ;; s		dired-sort-toggle-or-edit
      (define-key cpio-dired-mode-map "s" 'cpio-dired-sort-toggle-or-edit)
      ;; t		dired-toggle-marks
      (define-key cpio-dired-mode-map "t" 'cpio-dired-toggle-marks)
      ;; u		dired-unmark
      (define-key cpio-dired-mode-map "u" 'cpio-dired-unmark)
      ;; v		dired-view-file
      (define-key cpio-dired-mode-map "v" 'cpio-dired-view-entry)
      ;; w		dired-copy-filename-as-kill
      (define-key cpio-dired-mode-map "w" 'cpio-dired-copy-entry-name-as-kill)
      ;; x		dired-do-flagged-delete
      (define-key cpio-dired-mode-map "x" 'cpio-dired-do-flagged-delete)
      ;; y		dired-show-file-type
      (define-key cpio-dired-mode-map "y" 'cpio-dired-show-entry-type)
      ;; ~		dired-flag-backup-files
      (define-key cpio-dired-mode-map "~" 'cpio-dired-flag-backup-entries)
      ;; DEL		dired-unmark-backward
      (define-key cpio-dired-mode-map "\177" 'cpio-dired-unmark-backward)
      ;; S-SPC		scroll-down-command
      ;;;; Not in dired.el (define-key cpio-dired-mode-map "\S-SPC" 'cpio-scroll-down-command)
      ;; <follow-link>	mouse-face
      (define-key cpio-dired-mode-map [follow-link] 'cpio-mouse-face)
      ;; <mouse-2>	dired-mouse-find-file-other-window
      (define-key cpio-dired-mode-map "[mouse-2]" 'cpio-dired-mouse-find-entry-other-window)
      ;; <remap>		Prefix Command
      (define-key cpio-dired-mode-map "[remap]" nil)
      ;; 
      ;; C-t C-t		image-dired-dired-toggle-marked-thumbs
      (define-key cpio-dired-mode-map "\C-t\C-t" 'cpio-image-dired-dired-toggle-marked-thumbs)
      ;; 
      ;; C-t .		image-dired-display-thumb
      (define-key cpio-dired-mode-map "\C-t" 'cpio-image-dired-display-thumb)
      ;; C-t a		image-dired-display-thumbs-append
      (define-key cpio-dired-mode-map "\C-t" 'cpio-image-dired-display-thumbs-append)
      ;; C-t c		image-dired-dired-comment-files
      (define-key cpio-dired-mode-map "\C-t" 'cpio-image-dired-dired-comment-entries)
      ;; C-t d		image-dired-display-thumbs
      (define-key cpio-dired-mode-map "\C-t" 'cpio-image-dired-display-thumbs)
      ;; C-t e		image-dired-dired-edit-comment-and-tags
      (define-key cpio-dired-mode-map "\C-t" 'cpio-image-dired-dired-edit-comment-and-tags)
      ;; C-t f		image-dired-mark-tagged-files
      (define-key cpio-dired-mode-map "\C-t" 'cpio-image-dired-mark-tagged-entries)
      ;; C-t i		image-dired-dired-display-image
      (define-key cpio-dired-mode-map "\C-t" 'cpio-image-dired-dired-display-image)
      ;; C-t j		image-dired-jump-thumbnail-buffer
      (define-key cpio-dired-mode-map "\C-t" 'cpio-image-dired-jump-thumbnail-buffer)
      ;; C-t r		image-dired-delete-tag
      (define-key cpio-dired-mode-map "\C-t" 'cpio-image-dired-delete-tag)
      ;; C-t t		image-dired-tag-files
      (define-key cpio-dired-mode-map "\C-t" 'cpio-image-dired-tag-entries)
      ;; C-t x		image-dired-dired-display-external
      (define-key cpio-dired-mode-map "\C-t" 'cpio-image-dired-dired-display-external)
      ;; 
      ;; C-M-d		dired-tree-down
      (define-key cpio-dired-mode-map "\C-M-d" 'cpio-dired-tree-down)
      ;; C-M-n		dired-next-subdir
      (define-key cpio-dired-mode-map "\C-M-n" 'cpio-dired-next-subdir)
      ;; C-M-p		dired-prev-subdir
      (define-key cpio-dired-mode-map "\C-M-p" 'cpio-dired-prev-subdir)
      ;; C-M-u		dired-tree-up
      (define-key cpio-dired-mode-map "\C-M-u" 'cpio-dired-tree-up)
      ;; M-$		dired-hide-all
      (define-key cpio-dired-mode-map "\M-$" 'cpio-dired-hide-all)
      ;; M-s		Prefix Command
      (define-key cpio-dired-mode-map "\M-s" nil)
      ;; M-{		dired-prev-marked-file
      (define-key cpio-dired-mode-map "\M-{" 'cpio-dired-prev-marked-entry)
      ;; M-}		dired-next-marked-file
      (define-key cpio-dired-mode-map "\M-}" 'cpio-dired-next-marked-entry)
      ;; M-DEL		dired-unmark-all-files
      (define-key cpio-dired-mode-map "\M-\177" 'cpio-dired-unmark-all-entries)
      ;; 
      ;; M-s a		Prefix Command
      (define-key cpio-dired-mode-map "\M-sa" nil)
      ;; M-s f		Prefix Command
      (define-key cpio-dired-mode-map "\M-sf" nil)
      ;; 
      ;; % &		dired-flag-garbage-files
      (define-key cpio-dired-mode-map "%&" 'cpio-dired-flag-garbage-entries)
      ;; % C		dired-do-copy-regexp
      (define-key cpio-dired-mode-map "%C" 'cpio-dired-do-copy-regexp)
      ;; % H		dired-do-hardlink-regexp
      (define-key cpio-dired-mode-map "%H" 'cpio-dired-do-hardlink-regexp)
      ;; % R		dired-do-rename-regexp
      (define-key cpio-dired-mode-map "%R" 'cpio-dired-do-rename-regexp)
      ;; % S		dired-do-symlink-regexp
      (define-key cpio-dired-mode-map "%S" 'cpio-dired-do-symlink-regexp)
      ;; % d		dired-flag-files-regexp
      (define-key cpio-dired-mode-map "%d" 'cpio-dired-flag-entries-regexp)
      ;; % g		dired-mark-files-containing-regexp
      (define-key cpio-dired-mode-map "%g" 'cpio-dired-mark-entries-containing-regexp)
      ;; % l		dired-downcase
      (define-key cpio-dired-mode-map "%l" 'cpio-dired-downcase)
      ;; % m		dired-mark-files-regexp
      (define-key cpio-dired-mode-map "%m" 'cpio-dired-mark-entries-regexp)
      ;; % r		dired-do-rename-regexp
      (define-key cpio-dired-mode-map "%r" 'cpio-dired-do-rename-regexp)
      ;; % u		dired-upcase
      (define-key cpio-dired-mode-map "%u" 'cpio-dired-upcase)
      ;; 
      ;; * C-n		dired-next-marked-file
      (define-key cpio-dired-mode-map "*\C-n" 'cpio-dired-next-marked-entry)
      ;; * C-p		dired-prev-marked-file
      (define-key cpio-dired-mode-map "*\C-p" 'cpio-dired-prev-marked-entry)
      ;; * !		dired-unmark-all-marks
      (define-key cpio-dired-mode-map "*!" 'cpio-dired-unmark-all-marks)
      ;; * %		dired-mark-files-regexp
      (define-key cpio-dired-mode-map "*%" 'cpio-dired-mark-entries-regexp)
      ;; * *		dired-mark-executables
      (define-key cpio-dired-mode-map "**" 'cpio-dired-mark-executables)
      ;; * /		dired-mark-directories
      (define-key cpio-dired-mode-map "*/" 'cpio-dired-mark-directories)
      ;; * ?		dired-unmark-all-files
      (define-key cpio-dired-mode-map "*?" 'cpio-dired-unmark-all-entries)
      ;; * @		dired-mark-symlinks
      (define-key cpio-dired-mode-map "*@" 'cpio-dired-mark-symlinks)
      ;; * c		dired-change-marks
      (define-key cpio-dired-mode-map "*c" 'cpio-dired-change-marks)
      ;; * m		dired-mark
      (define-key cpio-dired-mode-map "*m" 'cpio-dired-mark) ;✓
      ;; * s		dired-mark-subdir-files
      (define-key cpio-dired-mode-map "*s" 'cpio-dired-mark-subdir-entries)
      ;; * t		dired-toggle-marks
      (define-key cpio-dired-mode-map "*t" 'cpio-dired-toggle-marks)
      ;; * u		dired-unmark
      (define-key cpio-dired-mode-map "*u" 'cpio-dired-unmark) ;✓
      ;; * DEL		dired-unmark-backward
      (define-key cpio-dired-mode-map "*\177" 'cpio-dired-unmark-backward)
      ;; 
      ;; : d		epa-dired-do-decrypt
      (define-key cpio-dired-mode-map ":d" 'cpio-epa-dired-do-decrypt)
      ;; : e		epa-dired-do-encrypt
      (define-key cpio-dired-mode-map ":e" 'cpio-epa-dired-do-encrypt)
      ;; : s		epa-dired-do-sign
      (define-key cpio-dired-mode-map ":s" 'cpio-epa-dired-do-sign)
      ;; : v		epa-dired-do-verify
      (define-key cpio-dired-mode-map ":v" 'cpio-epa-dired-do-verify)
      ;; 
      ;; <remap> <advertised-undo>	dired-undo
      (define-key cpio-dired-mode-map "[remap advertised-undo]" 'cpio-dired-undo)
      ;; <remap> <next-line>		dired-next-line
      (define-key cpio-dired-mode-map "[remap next-line]" 'cpio-dired-next-line)
      ;; <remap> <previous-line>		dired-previous-line
      (define-key cpio-dired-mode-map "[remap previous-line]" 'cpio-dired-previous-line)
      ;; <remap> <read-only-mode>	dired-toggle-read-only
      (define-key cpio-dired-mode-map "[remap read-only-mode]" 'cpio-dired-toggle-read-only)
      ;; <remap> <toggle-read-only>	dired-toggle-read-only
      (define-key cpio-dired-mode-map "[remap toggle-read-only]" 'cpio-dired-toggle-read-only)
      ;; <remap> <undo>			dired-undo
      (define-key cpio-dired-mode-map "[remap undo]" 'cpio-dired-undo)
      ;; 
      ;; M-s f C-s	dired-isearch-filenames
      (define-key cpio-dired-mode-map (kbd "M-s f C-s") 'cpio-dired-isearch-entry-names)
      ;; M-s f ESC	Prefix Command
      (define-key cpio-dired-mode-map "\M-sf" nil)
      ;;  
      ;; M-s a C-s	dired-do-isearch
      (define-key cpio-dired-mode-map (kbd "M-s a C-s") 'cpio-dired-do-isearch)
      ;; M-s a ESC	Prefix Command
      ;; 
      ;; M-s f C-M-s	dired-isearch-filenames-regexp
      (define-key cpio-dired-mode-map (kbd "M-s f C-M-s") 'cpio-dired-isearch-entry-names-regexp)
      ;; 
      ;; M-s a C-M-s	dired-do-isearch-regexp
      (define-key cpio-dired-mode-map (kbd "M-s a C-M-s") 'cpio-dired-do-isearch-regexp)
      ;; HEREHERE Uncomment this after development
      ;; (setq *cpio-have-made-keymap)
      )
    ))

(defalias 'cpio-dired-flag-auto-save-entries 'dired-flag-auto-save-files)
;; (defvar *cpio-dired-del-marker* ?D
;;   "Marker for flagging entries for deletion in cpio-dired-mode.")
;; (defun cpio-dired-flag-auto-save-entries (&optional unflag-p)
;;   "Flag for deletion entries whose names suggest they correspond to auto save files."
;;   (interactive "P")
;;   (let ((fname "cpio-dired-flag-auto-save-entries")
;; 	(cpio-dired-marker-char (if unflag-p ?\040 *cpio-dired-del-marker*)
;; 	)
;;     (error "%s() is not yet implemented" fname)
;;     ))


(cpio-dired-make-keymap)



(provide 'cpio-dired)
;;; cpio-dired.el ends here