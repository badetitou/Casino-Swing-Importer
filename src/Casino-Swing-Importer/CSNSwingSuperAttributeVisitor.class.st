Class {
	#name : #CSNSwingSuperAttributeVisitor,
	#superclass : #CSNModelVisitor,
	#instVars : [
		'superInvocation',
		'factory'
	],
	#category : #'Casino-Swing-Importer'
}

{ #category : #'as yet unclassified' }
CSNSwingSuperAttributeVisitor >> computeAttributesFrom: aSuperInvocation for: widget [
	superInvocation := aSuperInvocation.
	widget accept: self
	
]

{ #category : #accessing }
CSNSwingSuperAttributeVisitor >> factory [

	^ factory
]

{ #category : #accessing }
CSNSwingSuperAttributeVisitor >> factory: anObject [

	factory := anObject
]

{ #category : #visiting }
CSNSwingSuperAttributeVisitor >> visitCSNOriginedEntity: aCSNOriginedEntity [
	
]
