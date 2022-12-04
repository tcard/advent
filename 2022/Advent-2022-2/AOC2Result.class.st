Class {
	#name : #AOC2Result,
	#superclass : #Object,
	#category : #'Advent-2022-2'
}

{ #category : #'instance creation' }
AOC2Result class >> fromInput: input [
	(input = 'X') ifTrue: [ ^ AOC2Lose ].
	(input = 'Y') ifTrue: [ ^ AOC2Draw ].
	(input = 'Z') ifTrue: [ ^ AOC2Win ].
	self error: 'Unknown input'.

]
