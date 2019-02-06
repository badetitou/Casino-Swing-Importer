Extension { #name : #CSNUIPanel }

{ #category : #'*Casino-Swing-Importer' }
CSNUIPanel class >> swingCanHandle: anInvocation [
	^ #('JPanel' 'JScrollPane') includes: anInvocation invokedClassName
]
