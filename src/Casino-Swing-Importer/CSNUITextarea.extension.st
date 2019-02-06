Extension { #name : #CSNUITextarea }

{ #category : #'*Casino-Swing-Importer' }
CSNUITextarea class >> swingCanHandle: anInvocation [
	^ 'JTextArea' = anInvocation invokedClassName
]
