;; test hunchentoot in local

(in-package #:cl-user)

(defvar *local* t)

(defvar *build-dir* (pathname "."))

(pushnew :LOCAL-H *features*)

(load "heroku-setup.lisp")

(defvar *h-acceptor* (make-instance 'hunchentoot:easy-acceptor :port 8080))

(hunchentoot:start *h-acceptor*)
