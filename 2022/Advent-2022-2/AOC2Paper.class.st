Class {
	#name : #AOC2Paper,
	#superclass : #AOC2Shape,
	#category : #'Advent-2022-2'
}

{ #category : #'as yet unclassified' }
AOC2Paper class >> resultAgainst: other [
	^ (other = AOC2Rock) ifTrue: AOC2Win ifFalse: ((other = AOC2Scissors) ifTrue: AOC2Lose ifFalse: AOC2Draw).
]

{ #category : #'as yet unclassified' }
AOC2Paper class >> rivalForResult: result [
	(result = AOC2Win) ifTrue: [ ^ AOC2Scissors ].
	(result = AOC2Lose) ifTrue: [ ^ AOC2Rock ].
	^ super rivalForResult: result.

]

{ #category : #scoring }
AOC2Paper class >> score [
	^ 2.
]
