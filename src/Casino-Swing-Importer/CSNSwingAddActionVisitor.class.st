Class {
	#name : #CSNSwingAddActionVisitor,
	#superclass : #CSNModelVisitor,
	#instVars : [
		'actionToAdd',
		'factory'
	],
	#category : #'Casino-Swing-Importer'
}

{ #category : #visiting }
CSNSwingAddActionVisitor >> add: anAction to: aWidget [
	actionToAdd := anAction.
	^ aWidget accept: self
]

{ #category : #visiting }
CSNSwingAddActionVisitor >> visitCSNOriginedEntity: aCSNOriginedEntity [
	^ aCSNOriginedEntity addAction: actionToAdd
]
