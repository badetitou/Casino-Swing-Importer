Class {
	#name : #CSNSwingFactory,
	#superclass : #CSNWidgetFactory,
	#category : #'Casino-Swing-Importer'
}

{ #category : #factory }
CSNSwingFactory >> createPageFromInvocation: anInvocation [

	| page |
	page := CSNPage new
		        affectedActions: anInvocation affectation;
		        source: anInvocation;
		        yourself.
	page name: ((page variable
			  ifNotNil: [ :var | 
				  var receivingInvocations select: [ :invoc | 
					  invoc signature beginsWith: 'setTitle' ] ]
			  ifNil: [ {  } ])
			 ifEmpty: [ 
				 anInvocation parameters
					 at: 1
					 ifAbsent: [ 
					 page variable ifNotNil: [ :var | var name ] ifNil: [ anInvocation invokedClassName  ] ] ]
			 ifNotEmpty: [ :listInvocSetTitle | 
			 listInvocSetTitle first parameters first ]).
	self model silentlyAdd: page
]

{ #category : #factory }
CSNSwingFactory >> createWidgetFromSwingInvocation: anInvocation [

	| widget |
	widget := super createWidgetFor: anInvocation withParent: nil.
	widget
		affectedActions: anInvocation affectation;
		realClass: anInvocation invokedClass;
		name: (widget affectedActions
				 ifNil: [ anInvocation signature asString ]
				 ifNotNil: [ 
					 widget affectedActions isAccess
						 ifTrue: [ widget affectedActions to name ]
						 ifFalse: [ widget affectedActions name ] ]);
		source: anInvocation.
	^ self model silentlyAdd: widget
]
