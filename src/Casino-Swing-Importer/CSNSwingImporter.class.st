Class {
	#name : #CSNSwingImporter,
	#superclass : #BLWebModel,
	#category : #'Casino-Swing-Importer'
}

{ #category : #api }
CSNSwingImporter >> completeWidget: widget [
	"add the leaf to the widget"

	widget
		addAllWidgets:
			((widget variable receivingInvocations
				select: [ :invoc | #('add(' 'setViewportView(') anySatisfy: [ :addMethodString | invoc signature beginsWith: addMethodString ] ]
				thenCollect: [ :invoc | self searchWidgetFromAddInvocation: invoc ]) reject: #isNil)
]

{ #category : #api }
CSNSwingImporter >> createAllPages [
	(self sourceModel select: [ :a | a name = 'JFrame' ]) first withSubclassHierarchy
		do: [ :jFrameSubclass | 
			jFrameSubclass constructors
				do: [ :constructor | 
					(constructor incomingInvocations reject: [ :invocation | invocation from name = 'main' and: [ invocation from parentType name ~= 'Main' ] ])
						do: [ :invocation | self factory createPageFromInvocation: invocation ] ] ].
	^ self model
]

{ #category : #accessing }
CSNSwingImporter >> createFactory [
	factory := CSNSwingFactory new model: model; yourself
]

{ #category : #api }
CSNSwingImporter >> generatePage: aPage [
	aPage variable
		ifNotNil: [ :variable | 
			variable receivingInvocations
				select: [ :receivingInvocation | receivingInvocation signature beginsWith: 'setContentPane' ]
				thenDo: [ :invocation | aPage addWidget: (self searchWidgetFromAddInvocation: invocation) withInvocationOfAdd: invocation ] ]
		ifNil: [ "The page is instanciate inside a method... Maybe looking for as the page is the attribute of the invoked method ?" self flag: #todo ]
]

{ #category : #api }
CSNSwingImporter >> generateWidgets [
	self model allBLPage do: [ :page | self generatePage: page ]
]

{ #category : #api }
CSNSwingImporter >> import [
	self createAllPages.
	self generateWidgets
]

{ #category : #api }
CSNSwingImporter >> searchInstatiateVariable: var [
	^ ((var incomingAccesses select: #isWrite)
		flatCollect: [ :access | 
			access from outgoingInvocations
				select: [ :invoc | 
					access sourceAnchor startPos < invoc sourceAnchor startPos
						and: [ access sourceAnchor endPos + 5 > invoc sourceAnchor startPos ] ] ])
		ifEmpty: [ nil ]
		ifNotEmpty: [ :listOfinvocation | listOfinvocation first ]
]

{ #category : #api }
CSNSwingImporter >> searchWidgetFromAddInvocation: invocation [
	"search the widget added "

	| param var widget |
	param := invocation parameters
		at: 1
		ifAbsent: [ Exception signal: 'no parameter to find the added widget' ].
	var := invocation from localVariables select: [ :variable | variable name = param ].
	var
		ifEmpty: [ var := invocation from parentType attributes select: [ :attribute | attribute name = param ] ].
	var
		ifNotEmpty: [ "the added widget is a variable from somewhere else"
			| instanciationInvoc |
			instanciationInvoc := self searchInstatiateVariable: var first.
			instanciationInvoc ifNil: [ ^ nil ].
			widget := self factory createWidgetFromSwingInvocation: instanciationInvoc.
			widget isContainer
				ifTrue: [ self completeWidget: widget ] ].
	^ widget
]
