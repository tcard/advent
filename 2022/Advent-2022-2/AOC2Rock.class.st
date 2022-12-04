Class {
	#name : #AOC2Rock,
	#superclass : #AOC2Shape,
	#category : #'Advent-2022-2'
}

{ #category : #'as yet unclassified' }
AOC2Rock class >> resultAgainst: other [
	^ (other = AOC2Scissors) ifTrue: AOC2Win ifFalse: ((other = AOC2Paper) ifTrue: AOC2Lose ifFalse: AOC2Draw).
]

{ #category : #'as yet unclassified' }
AOC2Rock class >> rivalForResult: result [
	(result = AOC2Win) ifTrue: [ ^ AOC2Paper ].
	(result = AOC2Lose) ifTrue: [ ^ AOC2Scissors ].
	^ super rivalForResult: result.

]

{ #category : #scoring }
AOC2Rock class >> score [
	^ 1.
]
