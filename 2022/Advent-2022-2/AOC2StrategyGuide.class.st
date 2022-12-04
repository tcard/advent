Class {
	#name : #AOC2StrategyGuide,
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
AOC2StrategyGuide class >> fromInput: input [
	| lines guide parts shapeA shapeB |
	guide := self new.
	lines := input substrings: String cr.
	lines do: [ :line | 
		parts := line substrings: ' '.
		shapeA := AOC2Shape fromInput: (parts at: 1).
		shapeB := AOC2Shape fromInput: (parts at: 2).
		guide addMatch: (AOC2Match newWithShapes: shapeA and: shapeB). 
	].
	^ guide.
]

{ #category : #'instance creation' }
AOC2StrategyGuide class >> new [
	| guide |
	guide := super new.
	guide initialize.
	^ guide.
]

{ #category : #adding }
AOC2StrategyGuide >> addMatch: match [
	matches add: match.

]

{ #category : #initialization }
AOC2StrategyGuide >> initialize [
	matches := OrderedCollection new.

]

{ #category : #'as yet unclassified' }
AOC2StrategyGuide >> playerScore [
	^ (matches collect: [ :match | match playerScore ]) sum.
]
