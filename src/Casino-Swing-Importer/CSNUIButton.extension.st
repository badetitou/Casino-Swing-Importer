Extension { #name : #CSNUIButton }

{ #category : #'*Casino-Swing-Importer' }
CSNUIButton class >> swingCanHandle: anInvocation [
	^ 'JButton' = anInvocation invokedClassName
]
