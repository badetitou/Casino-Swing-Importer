Class {
	#name : #CSNSwingFactory,
	#superclass : #BLWidgetFactory,
	#category : #'Casino-Swing-Importer'
}

{ #category : #factory }
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
				ifNil: [ {} ]) ifEmpty: [ anInvocation parameters at:1 ifAbsent: [ nil ] ] ifNotEmpty: [ :listInvocSetTitle | listInvocSetTitle first parameters first ]).
	self model silentlyAdd: page
]

{ #category : #factory }
CSNSwingFactory >> createWidgetFromSwingInvocation: anInvocation [
	| widget |
	widget := (BLWidget createWidgetFromSwingInvocation: anInvocation).
	widget affectedActions: anInvocation affectation;
		realClass: anInvocation invokedClass;
		name: (widget affectedActions ifNil: [anInvocation signature asString] ifNotNil: [widget affectedActions isAccess ifTrue: [widget affectedActions to name] ifFalse: [widget affectedActions name]]);
		source: anInvocation.
	^ self model silentlyAdd: widget
]
