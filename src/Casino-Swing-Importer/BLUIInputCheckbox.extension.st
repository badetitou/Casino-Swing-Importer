Extension { #name : #BLUIInputCheckbox }

{ #category : #'*Casino-Swing-Importer' }
BLUIInputCheckbox class >> swingCanHandle: anInvocation [
	^ 'JCheckBox' = anInvocation invokedClassName
]
