;;; current-buffer.el --- Show the current Emacs buffer
;; Copyright (C) 2014, 2016  Free Software Foundation, Inc.

(if t (require 'htmlize))               ;Don't require during compilation.

(ws-start
 (lambda (request)
   (with-slots (process headers) request
     (ws-response-header process 200
       '("Content-type" . "text/html; charset=utf-8"))
     (process-send-string process
       (let ((html-buffer (htmlize-buffer)))
         (prog1 (with-current-buffer html-buffer (buffer-string))
           (kill-buffer html-buffer))))))
 9010)
