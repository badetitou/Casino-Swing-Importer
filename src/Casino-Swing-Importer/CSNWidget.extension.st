Extension { #name : #CSNWidget }

{ #category : #'*Casino-Swing-Importer' }
CSNWidget class >> createWidgetFromSwingInvocation: anInvocation [
	| class |
	class := self allSubclasses
		detect: [ :first | first swingCanHandle: anInvocation ]
		ifNone: [ ^ CSNContainer new ].
	^ class newSwingInstanceFor: anInvocation
]

{ #category : #'*Casino-Swing-Importer' }
CSNWidget class >> newSwingInstanceFor: anInvocation [
	^ self new
]

{ #category : #'*Casino-Swing-Importer' }
CSNWidget class >> swingCanHandle: anInvocation [
	^ false
]
