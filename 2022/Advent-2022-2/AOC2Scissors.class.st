Class {
	#name : #AOC2Scissors,
	#superclass : #AOC2Shape,
	#category : #'Advent-2022-2'
}

{ #category : #'as yet unclassified' }
AOC2Scissors class >> resultAgainst: other [
	^ (other = AOC2Paper) ifTrue: AOC2Win ifFalse: ((other = AOC2Rock) ifTrue: AOC2Lose ifFalse: AOC2Draw).
]

{ #category : #'as yet unclassified' }
AOC2Scissors class >> rivalForResult: result [
	(result = AOC2Win) ifTrue: [ ^ AOC2Rock ].
	(result = AOC2Lose) ifTrue: [ ^ AOC2Paper ].
	^ super rivalForResult: result.

]

{ #category : #scoring }
AOC2Scissors class >> score [
	^ 3.
]
