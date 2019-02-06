Extension { #name : #CSNUISelect }

{ #category : #'*Casino-Swing-Importer' }
CSNUISelect class >> swingCanHandle: anInvocation [
	^ 'JComboBox' = anInvocation invokedClassName
]
