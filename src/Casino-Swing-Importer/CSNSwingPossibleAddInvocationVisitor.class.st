Class {
	#name : #CSNSwingPossibleAddInvocationVisitor,
	#superclass : #CSNModelVisitor,
	#category : #'Casino-Swing-Importer'
}

{ #category : #visiting }
CSNSwingPossibleAddInvocationVisitor >> visitCSNOriginedEntity: aCSNOriginedEntity [

	^ { 'add('. 'setViewportView('. 'setContentPane'. 'setJMenuBar' }
		  asSet
]
