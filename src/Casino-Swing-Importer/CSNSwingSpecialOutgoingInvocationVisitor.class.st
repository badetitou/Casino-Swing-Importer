"
I return additionnal potential outgoing invocation if needed
"
Class {
	#name : #CSNSwingSpecialOutgoingInvocationVisitor,
	#superclass : #CSNModelVisitor,
	#instVars : [
		'currentInvocations'
	],
	#category : #'Casino-Swing-Importer'
}

{ #category : #visiting }
CSNSwingSpecialOutgoingInvocationVisitor >> additionalInvocationFor: aWidget withExistingInvocations: collectionOfInvocations [

	currentInvocations := collectionOfInvocations.
	^ aWidget accept: self
]

{ #category : #visiting }
CSNSwingSpecialOutgoingInvocationVisitor >> visitCSNOriginedEntity: aCSNOriginedEntity [
	^ Set new
]
