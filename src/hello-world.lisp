(in-package :cl-user)
(defvar *local* nil)

(in-package :example)

;; Utils
(defun heroku-getenv (target)
  #+ccl (ccl:getenv target)
  #+sbcl (sb-posix:getenv target))

(defun heroku-slug-dir ()
  (if cl-user::*local*
      "."
      (heroku-getenv "HOME")))

(defun db-params ()
  "Heroku database url format is postgres://username:password@host:port/database_name.
TODO: cleanup code."
  (let* ((url (second (cl-ppcre:split "//" (heroku-getenv "DATABASE_URL"))))
	 (user (if cl-user::*local*
               (heroku-getenv 'PS_USER) ; get Postgres login user form env var.
               (first (cl-ppcre:split ":" (first (cl-ppcre:split "@" url))))))
	 (password (if cl-user::*local*
                   (Heroku-getenv 'PS_PASS) ; get Postgres login password from env var.
                    (second (cl-ppcre:split ":" (first (cl-ppcre:split "@" url))))))
	 (host (if cl-user::*local*
               "localhost" ; Postgres host name.
                (first (cl-ppcre:split ":" (first (cl-ppcre:split "/" (second (cl-ppcre:split "@" url))))))))
	 (database (if cl-user::*local*
                   "heroku_cl_example"  ; Postgress database name.
                    (second (cl-ppcre:split "/" (second (cl-ppcre:split "@" url)))))))
    (list database user password host)))

;; Handlers

(push (hunchentoot:create-folder-dispatcher-and-handler "/static/" (concatenate 'string (heroku-slug-dir) "/public/")) hunchentoot:*dispatch-table*)

(hunchentoot:define-easy-handler (hello-sbcl :uri "/") ()
  (cl-who:with-html-output-to-string (s)
    (:html
     (:head
      (:title "Heroku CL Example App"))
     (:body
      (:h1 "Heroku CL Example App")
      (:h3 "Using")
      (:ul
       (:li (format s "~A ~A" (lisp-implementation-type) (lisp-implementation-version)))
       (:li (format s "Hunchentoot ~A" hunchentoot::*hunchentoot-version*))
       (:li (format s "CL-WHO")))
      (:div
       (:a :href "static/lisp-glossy.jpg" (:img :src "static/lisp-glossy.jpg" :width 100)))
      (:div
       (:a :href "static/hello.txt" "hello"))
      (:h3 "App Database")
      (:div
       (:pre "SELECT version();"))
      (:div (format s "~A" (postmodern:with-connection (db-params)
			     (postmodern:query "select version()"))))))))
