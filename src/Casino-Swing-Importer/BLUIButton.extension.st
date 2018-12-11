Extension { #name : #BLUIButton }

{ #category : #'*Casino-Swing-Importer' }
BLUIButton class >> swingCanHandle: anInvocation [
	^ 'JButton' = anInvocation invokedClassName
]
