; --- Day 3: Spiral Memory ---

; You come across an experimental new kind of memory stored on an infinite two-
; dimensional grid.

; Each square on the grid is allocated in a spiral pattern starting at a
; location marked 1 and then counting up while spiraling outward. For example,
; the first few squares are allocated like this:

; 17  16  15  14  13
; 18   5   4   3  12
; 19   6   1   2  11
; 20   7   8   9  10
; 21  22  23---> ...

; While this is very space-efficient (no squares are skipped), requested data
; must be carried back to square 1 (the location of the only access port for
; this memory system) by programs that can only move up, down, left, or right.
; They always take the shortest path: the Manhattan Distance between the
; location of the data and square 1.

; For example:

; Data from square 1 is carried 0 steps, since it's at the access port.
; Data from square 12 is carried 3 steps, such as: down, left, left.
; Data from square 23 is carried only 2 steps: up twice.
; Data from square 1024 must be carried 31 steps.

; How many steps are required to carry the data from the square identified in
; your puzzle input all the way to the access port?

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

(let (
  [cases (list
    (list 1 0)
    (list 12 3)
    (list 23 2)
    (list 1024 31)
  )]
) (for-each (lambda (case)
  (match-let (
    [(list input expected) case]
  ) (if (= (steps-to-center (nth-memory-position input)) expected)
      empty
      (error "bad")))
) cases))
