Extension { #name : #CSNUIInputText }

{ #category : #'*Casino-Swing-Importer' }
CSNUIInputText class >> swingCanHandle: anInvocation [
	^ 'JTextField' = anInvocation invokedClassName
]
