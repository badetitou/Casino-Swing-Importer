Extension { #name : #BLUISelect }

{ #category : #'*Casino-Swing-Importer' }
BLUISelect class >> swingCanHandle: anInvocation [
	^ 'JComboBox' = anInvocation invokedClassName
]
