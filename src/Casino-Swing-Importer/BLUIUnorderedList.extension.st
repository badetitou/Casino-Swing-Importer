Extension { #name : #BLUIUnorderedList }

{ #category : #'*Casino-Swing-Importer' }
BLUIUnorderedList class >> swingCanHandle: anInvocation [
	^ 'JList' = anInvocation invokedClassName
]
