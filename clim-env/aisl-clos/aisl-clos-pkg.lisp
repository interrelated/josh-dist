;;; -*- package: common-lisp-user; Mode: common-lisp-*-

(in-package :common-lisp-user)
;;; ======================================================================================
;;; needs to be "used" in conjunctoin with the package providing clos,
;;; usually this is the CL package - (defpackage my-appl-pkg (:use :CL :AISL-CLOS)) 

; "CLASS-SLOTS" not standard across implementations
; "OBJ-SLOTNAMES" not standard across implementations
; "GET-CLASS" "SUPERCLASSES*" "SUBCLASSES*" "OBJ-SLOTS" not standard across ...
; "OBJ-DIRECT-SLOTS*" "OBJ-READERNAMES*" not standard across implementations
; "CLASS-OF" "CLASS-NAME" these are ANSI, we shouldn't need to export them ... 

(defpackage aisl-clos 
  (:nicknames :portable-mop :pmop)
  (:use :cl #+MCL "CCL" #-MCL :clos)
  #+MCL (:shadow "CLASS-CLASS-SLOTS")
  #+MCL
  (:import-from "CCL"
		"COMPUTE-EFFECTIVE-METHOD" 
		"GENERIC-FUNCTION-METHOD-COMBINATION" 
		"SLOT-DEFINITION-INITARGS")
  (:export
    "CLASS"
    "CLASS-CLASS-SLOTS"
    "CLASS-DIRECT-CLASS-SLOTS"
    #+(or MCL allegro)
    "CLASS-DIRECT-DEFAULT-INITARGS"
    "CLASS-DIRECT-INSTANCE-SLOTS"
    #+(or MCL allegro)
    "CLASS-DIRECT-SLOTS"
    "CLASS-DIRECT-SUBCLASSES"
    #+(or MCL allegro Lispworks)
    "CLASS-DIRECT-SUPERCLASSES"
    "CLASS-INSTANCE-SLOTS"
    #+(or MCL Lispworks)
    "CLASS-PROTOTYPE"
    #+Lispworks
    "COMPUTE-APPLICABLE-METHODS"
    "COMPUTE-EFFECTIVE-METHOD"
    "FIND-APPLICABLE-METHODS"
    "FIND-CLASS"
    #+Lispworks
    "FUNCTION-KEYWORDS"
    #+(or MCL allegro)
    "GENERIC-FUNCTION-ARGUMENT-PRECEDENCE-ORDER"
    "GENERIC-FUNCTION"
    #+(or MCL allegro)
    "GENERIC-FUNCTION-LAMBDA-LIST"
    "GENERIC-FUNCTION-METHOD-COMBINATION"
    "GENERIC-FUNCTION-METHODS"
    "GENERIC-FUNCTION-NAME" 
    "METHOD"     
    "METHOD-FUNCTION"
    "METHOD-GENERIC-FUNCTION"
    "METHOD-QUALIFIERS"
    "METHOD-SPECIALIZERS"
    "SLOT-DEFINITION-ALLOCATION"
    #+(or MCL allegro Lispworks)
    "SLOT-DEFINITION-INITARGS"
    #+(or MCL allegro)
    "SLOT-DEFINITION-INITFORM"
    #+MCL
    "SLOT-DEFINITION-INITFUNCTION"
    "SLOT-DEFINITION-NAME"
    #-MCL
    "SLOT-DEFINITION-READERS"
    #+(or MCL allegro)
    "SLOT-DEFINITION-TYPE"
    #-MCL
    "SLOT-DEFINITION-WRITERS"
    "SPECIALIZER-DIRECT-METHODS" 
    "STANDARD-OBJECT"
    "STRUCTURE-OBJECT" ))
