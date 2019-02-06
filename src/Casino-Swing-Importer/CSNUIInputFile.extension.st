Extension { #name : #CSNUIInputFile }

{ #category : #'*Casino-Swing-Importer' }
CSNUIInputFile class >> swingCanHandle: anInvocation [
	^ 'JFileChooser' = anInvocation invokedClassName
]
