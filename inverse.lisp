(defun read-file (filename)
  (let (res)
    (with-open-file (fin filename)
      (do ((line (read-line fin nil nil)
                 (read-line fin nil nil)))
          ((null line) (reverse res))
        (push (parse-integer line) res)))))

(defun count-inverse-1 (alist &key (debug nil))
  (let ((count 0))
    (do ((a alist (cdr a)))
        ((null a) count)
      (dolist (b (cdr a))
        (if debug (format *debug-io* "comparing ~a ~a~%" (car a) b))
        (if (> (car a) b)
            (incf count))))))

(defun merge-count (a b &key (predicate #'<=) (result nil) (count 0))
  (cond
    ((or (null a) (null b)) 
     (values (append (reverse result) a b) count))
    (t
     (if (funcall predicate (car a) (car b))
         (merge-count (cdr a) b :predicate predicate
                      :result (cons (car a) result)
                      :count count)
         (merge-count a (cdr b) :predicate predicate
                      :result (cons (car b) result)
                      :count (+ count (length a)))))))

(defun count-inverse (alist &key (predicate #'<=))
  (let ((m (round (length alist) 2)))
    (if (<= m 0)
        (values alist 0)
        (let ((res1 (multiple-value-list (count-inverse (subseq alist 0 m)
                                                        :predicate predicate)))
              (res2 (multiple-value-list (count-inverse (subseq alist m)
                                                        :predicate predicate))))
          (multiple-value-bind (newlist c)
              (merge-count (car res1) (car res2)
                           :predicate predicate :result nil :count 0)
            (values newlist (+ (cadr res1) (cadr res2) c)))))))