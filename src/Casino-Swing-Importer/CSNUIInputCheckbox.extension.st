Extension { #name : #CSNUIInputCheckbox }

{ #category : #'*Casino-Swing-Importer' }
CSNUIInputCheckbox class >> swingCanHandle: anInvocation [
	^ 'JCheckBox' = anInvocation invokedClassName
]
