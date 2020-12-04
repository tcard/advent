; --- Part Two ---

; As a stress test on the system, the programs here clear the grid and then
; store the value 1 in square 1. Then, in the same allocation order as shown
; above, they store the sum of the values in all adjacent squares, including
; diagonals.

; So, the first few squares' values are chosen as follows:

; Square 1 starts with the value 1.
; Square 2 has only one adjacent filled square (with value 1), so it also stores
; 1.
; Square 3 has both of the above squares as neighbors and stores the sum of
; their values, 2.
; Square 4 has all three of the aforementioned squares as neighbors and stores
; the sum of their values, 4.
; Square 5 only has the first and fourth squares as neighbors, so it gets the
; value 5.

; Once a square is written, its value does not change. Therefore, the first few
; squares would receive the following values:

; 147  142  133  122   59
; 304    5    4    2   57
; 330   10    1    1   54
; 351   11   23   25   26
; 362  747  806--->   ...

; What is the first value written that is larger than your puzzle input?

#lang racket

(require racket/stream)

(struct state (
  dir
  steps
  turned
) #:transparent)

(define (advance-state s)
  (match-let* (
    [(state dir steps turned) s]
    [next-dir (match dir
      ['right 'up]
      ['up 'left]
      ['left 'down]
      ['down 'right]
    )]
    [next-steps (if turned (+ steps 1) steps)]
    [next-turned (not turned)]
  ) (state next-dir next-steps next-turned)))

(struct point (x y)
  #:transparent)

(define (walk-state s pos)
  (match-letrec (
    [(state dir steps _) s]

    [walk-step
      (lambda (pos)
        (match-let (
          [(point x y) pos]
        ) (match dir
            ['right
              (point (+ x 1) y)]
            ['up
              (point x (+ y 1))]
            ['left
              (point (- x 1) y)]
            ['down
              (point x (- y 1))]
        )))]

    [walk (lambda (steps-left pos)
      (if (= steps-left 0)
        empty-stream
        (let (
          [next-pos (walk-step pos)]
        ) (stream-cons next-pos (walk (- steps-left 1) next-pos)))))]

  ) (walk steps pos)))

(define (positions s pos)
  (letrec (
    [state-positions (walk-state s pos)]
    [next-state (advance-state s)]
    [concat-states (lambda (state-positions pos)
      (if (stream-empty? state-positions)
        (positions next-state pos)
        (let (
          [next-pos (stream-first state-positions)]
          [rest-state-positions (stream-rest state-positions)]
        ) (stream-cons next-pos (concat-states rest-state-positions next-pos)))))]
  ) (concat-states state-positions pos)))

(define initial-state (state 'right 1 #f))
(define initial-pos (point 0 0))

(define memory-positions
  (stream-cons initial-pos (positions initial-state initial-pos)))

(define (steps-to-center p)
  (match-let (
    [(point x y) p]
  ) (+ (abs x) (abs y))))

(define (nth-memory-position n)
  (stream-ref memory-positions (- n 1)))

; I couldn't find this in the standard library. ????
(define (take n s)
  (if (= n 0)
    empty-stream
    (stream-cons (stream-first s) (take (- n 1) (stream-rest s)))))

(define (adjacent pos)
  (match-let (
    [(point x y) pos]
  ) (list
    (point (+ x 1) y)
    (point (+ x 1) (+ y 1))
    (point x (+ y 1))
    (point (- x 1) (+ y 1))
    (point (- x 1) y)
    (point (- x 1) (- y 1))
    (point x (- y 1))
    (point (+ x 1) (- y 1))
  )))

(define memory-values
  (letrec (
    [values (make-hash)]
    [get-value (lambda (pos)
      (hash-ref values pos
        (lambda ()
          (let* (
            [adjacent-values (map (lambda (pos)
              (hash-ref values pos 0)
            ) (adjacent pos))]
            [value (foldl + 0 adjacent-values)]
          )
            (hash-set! values pos value)
            value))))]
    [make-stream (lambda (memory-positions)
      (let* (
        [pos (stream-first memory-positions)]
        [rest-memory-positions (stream-rest memory-positions)]
        [value (get-value pos)]
      )
        (stream-cons value (make-stream rest-memory-positions))))]
  )
    (hash-set! values initial-pos 1)
    (make-stream memory-positions)))

(define (nth-memory-value n)
  (stream-ref memory-values (- n 1)))

(let (
  [cases (list
    (list 1 1)
    (list 2 1)
    (list 3 2)
    (list 4 4)
    (list 5 5)
    (list 9 25)
    (list 14 122)
  )]
) (for-each (lambda (case)
  (match-let (
    [(list input expected) case]
  ) 
    (if (= (nth-memory-value input) expected)
      empty
      (error "bad")))
) cases))

(define (first-value-larger-than n)
  (letrec (
    [iter (lambda (memory-values)
      (let (
        [next-value (stream-first memory-values)]
      ) (if (> next-value n)
          next-value
          (iter (stream-rest memory-values)))))]
  ) (iter memory-values)))
