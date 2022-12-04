Class {
	#name : #AOC2Solver,
	#superclass : #Object,
	#category : #'Advent-2022-2'
}

{ #category : #'as yet unclassified' }
AOC2Solver class >> solvePart1ForInput: input [
	| guide |
	guide := AOC2StrategyGuide fromInput: input.
	^ guide playerScore.
]

{ #category : #'as yet unclassified' }
AOC2Solver class >> solvePart2ForInput: input [
	| guide |
	guide := AOC2StrategyGuide2 fromInput: input.
	^ guide playerScore.
]
