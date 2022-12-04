Class {
	#name : #AOC2StrategyGuide2,
	#superclass : #Object,
	#instVars : [
		'matches'
	],
	#classInstVars : [
		'matches'
	],
	#category : #'Advent-2022-2'
}

{ #category : #'instance creation' }
AOC2StrategyGuide2 class >> fromInput: input [
	| lines guide parts shapeA shapeB |
	guide := self new.
	lines := input substrings: String cr.
	lines do: [ :line | 
		parts := line substrings: ' '.
		shapeA := AOC2Shape fromInput: (parts at: 1).
		shapeB := shapeA rivalForResult: (AOC2Result fromInput: (parts at: 2)).
		guide addMatch: (AOC2Match newWithShapes: shapeA and: shapeB).
	].
	^ guide.
]

{ #category : #'instance creation' }
AOC2StrategyGuide2 class >> new [
	| guide |
	guide := super new.
	guide initialize.
	^ guide.
]

{ #category : #adding }
AOC2StrategyGuide2 >> addMatch: match [
	matches add: match.

]

{ #category : #initialization }
AOC2StrategyGuide2 >> initialize [
	matches := OrderedCollection new.

]

{ #category : #'as yet unclassified' }
AOC2StrategyGuide2 >> playerScore [
	^ (matches collect: [ :match | match playerScore ]) sum.
]
