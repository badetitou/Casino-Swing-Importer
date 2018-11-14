Class {
	#name : #CSNSwingFactory,
	#superclass : #BLWidgetFactory,
	#category : #'Casino-Swing-Importer'
}

{ #category : #'as yet unclassified' }
CSNSwingFactory >> createPageFromInvocation: anInvocation [
	| page |
	page := BLPage new
		affectedActions: anInvocation affectation;
		source: anInvocation;
		yourself.
	page
		name:
			((page variable
				ifNotNil: [ :var |  var receivingInvocations select: [ :invoc | invoc signature beginsWith: 'setTitle' ] ]
				ifNil: [ {} ]) ifEmpty: [ nil ] ifNotEmpty: [ :listInvocSetTitle | listInvocSetTitle first parameters first ]).
	self model silentlyAdd: page
]

{ #category : #'as yet unclassified' }
CSNSwingFactory >> createWidgetFromSwingInvocation: anObject [
	| widget |
	widget := (BLWidget createWidgetFromSwingInvocation: anObject).
	widget affectedActions: anObject affectation.
	^ self model silentlyAdd: widget
]
