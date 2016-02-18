;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Package: CLIM-INTERNALS; Base: 10; Lowercase: Yes -*-

(defun accept-sequence-element (stream element-type view separators
                                element-default element-default-type default-supplied-p)
  (declare (values object object-type))
  (LET ((BUFFER-START (STREAM-SCAN-POINTER STREAM)))
  (multiple-value-bind (object object-type)
      (with-input-context (element-type) (object object-type)
           (with-delimiter-gestures (separators)
             (let* ((history (presentation-type-history element-default-type))
                    (*presentation-type-for-yanking*
                      (if history element-default-type *presentation-type-for-yanking*))
                    (default-element
                      (and history
                           (make-presentation-history-element
                             :object element-default :type element-default-type))))
               (if default-supplied-p
                   (if history
                       (with-default-bound-in-history history default-element
                         (funcall-presentation-generic-function accept
                           element-type stream view
                           :default element-default :default-type element-default-type))
                       (funcall-presentation-generic-function accept
                         element-type stream view
                         :default element-default :default-type element-default-type))
                   (funcall-presentation-generic-function accept
                     element-type stream view))))
         ;; The user clicked on an object having the element type
         (t
	  (presentation-replace-input stream object object-type view
				      :BUFFER-START BUFFER-START)
           (values object object-type)))
    (values object object-type))))