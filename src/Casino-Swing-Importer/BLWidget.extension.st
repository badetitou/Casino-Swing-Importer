Extension { #name : #BLWidget }

{ #category : #'*Casino-Swing-Importer' }
BLWidget class >> createWidgetFromSwingInvocation: anInvocation [
	| class |
	class := self allSubclasses
		detect: [ :first | first swingCanHandle: anInvocation ]
		ifNone: [ ^ nil ].
	^ class newSwingInstanceFor: anInvocation
]

{ #category : #'*Casino-Swing-Importer' }
BLWidget class >> newSwingInstanceFor: anInvocation [
	^ self new
]

{ #category : #'*Casino-Swing-Importer' }
BLWidget class >> swingCanHandle: anInvocation [
	^ false
]
