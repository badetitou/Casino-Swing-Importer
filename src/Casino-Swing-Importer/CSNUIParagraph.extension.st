Extension { #name : #CSNUIParagraph }

{ #category : #'*Casino-Swing-Importer' }
CSNUIParagraph class >> swingCanHandle: anInvocation [
	^ 'JLabel' = anInvocation invokedClassName
]
