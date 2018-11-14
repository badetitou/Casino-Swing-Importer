Extension { #name : #BLUIPanel }

{ #category : #'*Casino-Swing-Importer' }
BLUIPanel class >> swingCanHandle: anInvocation [
	^ 'JPanel' = anInvocation invokedClassName
]
