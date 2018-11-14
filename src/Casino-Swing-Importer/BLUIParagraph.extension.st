Extension { #name : #BLUIParagraph }

{ #category : #'*Casino-Swing-Importer' }
BLUIParagraph class >> swingCanHandle: anInvocation [
	^ 'JLabel' = anInvocation invokedClassName
]
