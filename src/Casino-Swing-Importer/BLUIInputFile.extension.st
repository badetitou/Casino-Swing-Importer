Extension { #name : #BLUIInputFile }

{ #category : #'*Casino-Swing-Importer' }
BLUIInputFile class >> swingCanHandle: anInvocation [
	^ 'JFileChooser' = anInvocation invokedClassName
]
