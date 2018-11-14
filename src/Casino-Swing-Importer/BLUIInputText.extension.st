Extension { #name : #BLUIInputText }

{ #category : #'*Casino-Swing-Importer' }
BLUIInputText class >> swingCanHandle: anInvocation [
	^ 'JTextField' = anInvocation invokedClassName
]
