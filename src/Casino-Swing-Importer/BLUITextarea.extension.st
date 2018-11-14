Extension { #name : #BLUITextarea }

{ #category : #'*Casino-Swing-Importer' }
BLUITextarea class >> swingCanHandle: anInvocation [
	^ 'JTextArea' = anInvocation invokedClassName
]
