Class {
	#name : #CSNSwingPossibleAddInvocationVisitor,
	#superclass : #CSNModelVisitor,
	#instVars : [
		'invocation'
	],
	#category : #'Casino-Swing-Importer'
}

{ #category : #accessing }
CSNSwingPossibleAddInvocationVisitor >> invocation [

	^ invocation
]

{ #category : #accessing }
CSNSwingPossibleAddInvocationVisitor >> invocation: anObject [

	invocation := anObject
]

{ #category : #visiting }
CSNSwingPossibleAddInvocationVisitor >> visitCSNOriginedEntity: aCSNOriginedEntity [

	^ { 'add('. 'setViewportView('. 'setContentPane'. 'setJMenuBar' } 
		  anySatisfy: [ :keyword | invocation signature beginsWith: keyword ]
]
