 ;;; -*- Mode: LISP; Syntax: Common-Lisp; Package: Ideal;  Base: 10 -*-

(in-package :ideal)


;;;;********************************************************
;;;;  Copyright (c) 1989, 1992 Rockwell International -- All rights reserved.
;;;;  Rockwell International Science Center Palo Alto Lab
;;;;********************************************************

;;;;;;;;;;;;;;;;;;;;;;;; Sampath ;;;;;;;;;;;;;;;;;;;;




(export '(UNIV CREATE-JENSEN-JOIN-TREE))
;--------------------------------------------------------------------------

(defstruct (jensen-join-tree (:print-function print-jensen-join-tree))
  univs sepsets root-univ)

(defun print-jensen-join-tree (n s d)
  (declare (ignore  n d))
  (format s "#<Jensen Join Tree>"))

(defstruct (univ (:print-function print-univ))
  component-nodes
  initial-dist-array
  dist-array
  sepset-neighbours
	; The following field should actually be called state-space-size
  cardinality
  evidence-univ-p
  potential-members
  ev-subtree-member-p
  ev-subtree-leaf-p)

(defun print-univ (n s d)
  (declare (ignore d))
  (format s "#<Univ ~A>" (node-names (univ-component-nodes n))))

(defstruct (sepset (:print-function print-sepset))
  component-nodes
  initial-potential-array
  potential-array
  transmission-array
  univ-neighbours
  changed-p
   ; The following field should actually be called state-space-size
  cardinality)

(defun print-sepset (n s d)
  (declare (ignore d))
  (format s "#<Sep ~A>" (node-names (sepset-component-nodes n))))

;---- Access fns ---

(defun univ-potential-of (univ univ-case)
  (read-probability-array (univ-dist-array univ)
			  univ-case
			  (univ-component-nodes univ)))

(defsetf univ-potential-of (univ univ-case)(value)
  (let ((univ-var (gentemp "univ")))
    `(let ((,univ-var ,univ))
       (write-probability-array (univ-dist-array ,univ-var)
				,univ-case
				(univ-component-nodes ,univ-var)
				,value))))

(defun sepset-potential-of (sepset sepset-case)
  (read-probability-array (sepset-potential-array sepset)
			  sepset-case
			  (sepset-component-nodes sepset)))

(defsetf sepset-potential-of (sepset sepset-case)(value)
  (let ((sepset-var (gentemp "sepset")))
    `(let ((,sepset-var ,sepset))
       (write-probability-array (sepset-potential-array ,sepset-var)
				,sepset-case
				(sepset-component-nodes ,sepset-var)
				,value))))

(defun sepset-transmission-potential-of (sepset sepset-case)
  (read-probability-array (sepset-transmission-array sepset)
			  sepset-case
			  (sepset-component-nodes sepset)))

(defsetf sepset-transmission-potential-of (sepset sepset-case)(value)
  (let ((sepset-var (gentemp "sepset")))
    `(let ((,sepset-var ,sepset))
       (write-probability-array (sepset-transmission-array ,sepset-var)
				,sepset-case
				(sepset-component-nodes ,sepset-var)
				,value))))

;--------------------------------------------
; Utilities

(defun sepsets-other-univ (s univ)
  (find-if-not #'(lambda (u)(eq u univ)) (sepset-univ-neighbours s)))

;-----------------------------------------------------------------

; The input is a join tree topology in the format returned by the fn
; find-join-tree-structure.

(defun create-jensen-join-tree (belief-net)
  (let* ((join-tree
	   (create-join-tree-topology (unlink-all-dummy-nodes belief-net)))
	 (root-univ (choose-root-univ join-tree)))
    (set-diagram-initialization belief-net :algorithm-type :JENSEN)
    (ideal-debug-msg "~% Initializing univ potentials-----~%")
    (initialize-join-tree-potentials join-tree belief-net)
    (ideal-debug-msg "~% Collecting evidence ---:Root univ is: ~A~%" root-univ)
    (complete-collect-evidence root-univ)
    (ideal-debug-msg "~% Distributing evidence -----~%")
    (distribute-evidence root-univ)
    (cache-potentials join-tree)
    (values join-tree)))

; Note that the univ-list in the join tree has the univs sorted by increasing
; order of cardinality.



(defun create-join-tree-topology (belief-net)
  (let* ((join-tree-structure (find-join-tree-structure belief-net))
	 (univ-list (mapcar
		      #'(lambda (jtn)(make-univ :component-nodes (jt-node-clique jtn)))
		      join-tree-structure))
	 (sepset-list nil)
	 univ parent-univ sepset)
    (dolist (jtnode join-tree-structure)
      (setf univ
	    (find (jt-node-clique jtnode) univ-list :key #'univ-component-nodes))
      (setf (univ-cardinality univ)
	    (product-over (n (univ-component-nodes univ))(number-of-states n)))
      (when (jt-node-parent jtnode)
	(setf parent-univ
	      (find (jt-node-clique
		      (jt-node-parent jtnode)) univ-list :key #'univ-component-nodes))
	(setf sepset
	      (create-sepset univ parent-univ))
	(push sepset
	      (univ-sepset-neighbours univ))
	(push sepset
	      (univ-sepset-neighbours parent-univ))
	(push sepset
	      sepset-list)))
    (values (make-jensen-join-tree
	      :univs (sort univ-list #'< :key #'univ-cardinality)
	      :sepsets sepset-list))))

(defun create-sepset (univ parent-univ)
  (let ((comp-nodes  (intersection (univ-component-nodes univ)
				   (univ-component-nodes parent-univ))))
    (make-sepset :component-nodes comp-nodes
		 :univ-neighbours (list univ parent-univ)
		 :cardinality (product-over (c comp-nodes)(number-of-states c)))))


(defun initialize-join-tree-potentials (join-tree belief-net)
  (dolist (s (jensen-join-tree-sepsets join-tree))
    (setf (sepset-potential-array s)
	  (make-array (sepset-cardinality s) :initial-element 1)
	  (sepset-initial-potential-array s)
	  (make-array (sepset-cardinality s))
	  (sepset-transmission-array s)
	  (make-array (sepset-cardinality s))))
  ; Assigning each belief net node to the potential fn of one univ
  (dolist (n belief-net)
    (push n (univ-potential-members (find-potential-univ n join-tree))))
  (dolist (univ (jensen-join-tree-univs join-tree))
    (initialize-univ-potentials univ))
  (values join-tree))

(defun find-potential-univ (n join-tree)
  (or (find n (jensen-join-tree-univs join-tree) :test #'includable-in-potential)
      (error "Cant find a univ to include ~A's potential in join tree ~A" n join-tree)))

(defun includable-in-potential (node univ)
  (and (member node (univ-component-nodes univ))
       (subsetp (node-predecessors node) (univ-component-nodes univ))))

 (defun initialize-univ-potentials (univ)
  (ideal-debug-msg "~% Intializing potentials for ~A" univ)
	; Setting up potential array
  (setf (univ-dist-array univ)(make-array (univ-cardinality univ))
	(univ-initial-dist-array univ)(make-array (univ-cardinality univ)))
  (let ((potential-nodes (univ-potential-members univ)))
    (labels ((member-of-potential (node.state)(member (car node.state) potential-nodes)))
	; Setting potentials
      (for-all-cond-cases (univ-case (univ-component-nodes univ))
      	(setf (univ-potential-of univ univ-case)
	      (product-over (node.state (remove-if-not #'member-of-potential univ-case))
		(prob-of (list node.state) univ-case)))))))



;------------------------

; Caching and reverting potentials

(defun cache-potentials (join-tree)
  (dolist (u (jensen-join-tree-univs join-tree))
    (replace (univ-initial-dist-array u)(univ-dist-array u)))
  (dolist (s (jensen-join-tree-sepsets join-tree))
    (replace (sepset-initial-potential-array s)(sepset-potential-array s))))


(defun revert-potentials (join-tree)
  (dolist (u (jensen-join-tree-univs join-tree))
    (replace (univ-dist-array u)(univ-initial-dist-array u)))
  (dolist (s (jensen-join-tree-sepsets join-tree))
    (replace (sepset-potential-array s)(sepset-initial-potential-array s))))

(defun reset-activations (join-tree)
  (dolist (u (jensen-join-tree-univs join-tree))
    (setf (univ-evidence-univ-p u) nil
	  (univ-ev-subtree-member-p u) nil
	  (univ-ev-subtree-leaf-p u) nil))
  (dolist (s (jensen-join-tree-sepsets join-tree))
    (setf (sepset-changed-p s) nil)))
