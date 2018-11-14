Extension { #name : #BLUIInputNumber }

{ #category : #'*Casino-Swing-Importer' }
BLUIInputNumber class >> swingCanHandle: anInvocation [
	^ 'JSpinner' = anInvocation invokedClassName
]
