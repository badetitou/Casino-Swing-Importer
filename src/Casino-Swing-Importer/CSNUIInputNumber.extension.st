Extension { #name : #CSNUIInputNumber }

{ #category : #'*Casino-Swing-Importer' }
CSNUIInputNumber class >> swingCanHandle: anInvocation [
	^ 'JSpinner' = anInvocation invokedClassName
]
