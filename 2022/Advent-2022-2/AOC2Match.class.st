Class {
	#name : #AOC2Match,
	#superclass : #Object,
	#instVars : [
		'shapeA',
		'shapeB'
	],
	#category : #'Advent-2022-2'
}

{ #category : #'instance creation' }
AOC2Match class >> newWithShapes: a and: b [
	"comment stating purpose of class-side method"
	"scope: class-variables  &  class-instance-variables"	
			
	| match |
	match := self new.
	match setShapes:a and: b.
	^ match.

]

{ #category : #'as yet unclassified' }
AOC2Match >> playerScore [
	| shapeScore matchScore |
	shapeScore := shapeB score.
	matchScore := (shapeB resultAgainst: shapeA) score.
	^ shapeScore + matchScore.
]

{ #category : #initialization }
AOC2Match >> setShapes: a and: b [
	shapeA := a.
	shapeB := b.
]
