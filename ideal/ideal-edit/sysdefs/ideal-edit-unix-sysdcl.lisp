;;; -*- Mode: LISP; Syntax: Common-Lisp; Base: 10; Package: COMMON-LISP-USER -*-(in-package :cl-user);;;;********************************************************;;;;  Copyright (c) 1989, 1992 Rockwell International -- All rights reserved.;;;;  Rockwell International Science Center Palo Alto Lab;;;;********************************************************#|File:      ideal-edit-unix-sysdcl.lispDescription:  System file for IDEAL-EDIT - unix systemsNotes:|#(unless (find-package :ideal-edit)  (make-package "IDEAL-EDIT" :use '(:clim-lisp :clim));;  (shadowing-import '(clim:interactive-stream-p clim:truename clim:pathname))  ); Exports from IDEAL-EDIT package and other package details(export '(init-x run-editor rerun-editor *editor* *diagram-cliques* *diagram-join-tree*))(proclaim '(special clim-user::*clim-root*))(defparameter *ideal-edit-src-directory*  (translate-logical-pathname "ideal-edit:code;"))(defparameter *ideal-edit-bin-directory*  (translate-logical-pathname "ideal-edit:code;"))(clim-defsys:defsystem ideal-edit  (:default-pathname *ideal-edit-src-directory*      :default-binary-pathname *ideal-edit-bin-directory*      :needed-systems ()      :load-before-compile ())  ("interface")  ("nodes")  ("node-internals")  ("graph-editor")  ("graph-edit")  ("display")  ("file-io")  ("solutions")  ("node-edit")  ("node-tables");; ("noisy-or-nodes") ; Skip this for now  ("id-commands")  )(defun compile-ideal-edit-system (&rest keys)  (apply #'clim-defsys:compile-system 'ideal-edit keys)  )(defun load-ideal-edit-system (&rest load-system-args)  (apply #'clim-defsys:load-system 'ideal-edit load-system-args)  )