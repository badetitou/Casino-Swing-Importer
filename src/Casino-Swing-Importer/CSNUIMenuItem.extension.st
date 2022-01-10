Extension { #name : #CSNUIMenuItem }

{ #category : #'*Casino-Swing-Importer' }
CSNUIMenuItem class >> swingCanHandle: anInvocation [
	^ 'JMenuItem' = anInvocation invokedClassName
]
