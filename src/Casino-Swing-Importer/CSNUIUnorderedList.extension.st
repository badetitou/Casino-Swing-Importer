Extension { #name : #CSNUIUnorderedList }

{ #category : #'*Casino-Swing-Importer' }
CSNUIUnorderedList class >> swingCanHandle: anInvocation [
	^ 'JList' = anInvocation invokedClassName
]
