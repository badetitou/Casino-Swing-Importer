Extension { #name : #BLUIInputButton }

{ #category : #'*Casino-Swing-Importer' }
BLUIInputButton class >> swingCanHandle: anInvocation [
	^ 'JButton' = anInvocation invokedClassName
]
