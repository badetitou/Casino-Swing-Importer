Extension { #name : #CSNUIMenu }

{ #category : #'*Casino-Swing-Importer' }
CSNUIMenu class >> swingCanHandle: anInvocation [
	^ 'JMenu' = anInvocation invokedClassName
]
