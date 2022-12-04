Class {
	#name : #AOC2Shape,
	#superclass : #Object,
	#category : #'Advent-2022-2'
}

{ #category : #'instance creation' }
AOC2Shape class >> fromInput: input [
	((input = 'A') or: [input = 'X']) ifTrue: [ ^ AOC2Rock ].
	((input = 'B') or: [input = 'Y']) ifTrue: [ ^ AOC2Paper ].
	((input = 'C') or: [input = 'Z']) ifTrue: [ ^ AOC2Scissors ].
	self error: 'Unknown input'.

]

{ #category : #'as yet unclassified' }
AOC2Shape class >> rivalForResult: result [
	(result = result) ifTrue: [ ^ self ].
]
