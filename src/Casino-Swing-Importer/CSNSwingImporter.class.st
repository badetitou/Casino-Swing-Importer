Class {
	#name : #CSNSwingImporter,
	#superclass : #BLWebModel,
	#category : #'Casino-Swing-Importer'
}

{ #category : #api }
CSNSwingImporter >> completeWidget: widget [
	"add the leaf to the widget"
	"self haltIf: [ widget variable name = 'analyzerPanel' ]."
	widget
		addAllWidgets:
			((widget variable receivingInvocations
				select: [ :invoc | 
					#('add(' 'setViewportView(')
						anySatisfy: [ :addMethodString | invoc signature beginsWith: addMethodString ] ]
				thenCollect: [ :invoc | self searchWidgetFromAddInvocation: invoc ]) reject: #isNil)
]

{ #category : #api }
CSNSwingImporter >> createAllPages [
	(self sourceModel allClasses select: [ :a | a name = 'JFrame' ]) first withSubclassHierarchy
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
	| invocations |
	"self haltIf: [ aPage name = 'cfm' ]."
	invocations := OrderedCollection new.
	(aPage source invokedClass superclassHierarchy anySatisfy: [:class | class name = 'JFrame']) ifTrue: [
		invocations addAll: aPage source to first outgoingInvocations.
		invocations addAll: (aPage source to first classes collect: #outgoingInvocations).
		].
	invocations addAll: (aPage variable
		ifNotNil: [ :variable | 
			variable receivingInvocations ]
		ifNil: [ "The page is instanciate inside a method... Maybe looking for as the page is the attribute of the invoked method ?" self flag: #todo.{} ]).
	(invocations flattened select: [ :receivingInvocation | #('setContentPane' 'add(') anySatisfy: [ :keyword | receivingInvocation signature beginsWith: keyword ] ]) do: [ :invocation | aPage addWidget: (self searchWidgetFromAddInvocation: invocation) withInvocationOfAdd: invocation ]
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
	| listOfinvocation | 
	listOfinvocation := ((var incomingAccesses select: #isWrite)
		flatCollect: [ :access | 
			access from outgoingInvocations
				select: [ :invoc | 
					access sourceAnchor startPos < invoc sourceAnchor startPos
						and: [ access sourceAnchor endPos + 5 > invoc sourceAnchor startPos ] ] ]).
	listOfinvocation 
		ifEmpty: [ listOfinvocation :=var parentBehaviouralEntity outgoingInvocations select: [ :invoc | 
					var sourceAnchor startPos < invoc sourceAnchor startPos
						and: [ var sourceAnchor endPos + 5 > invoc sourceAnchor startPos ] ] ].
	listOfinvocation ifEmpty: [ ^ nil ]
		ifNotEmpty: [  ^ listOfinvocation first ]	""
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
		ifEmpty: [ 
			| possibleAttributes tmpClass |
			possibleAttributes := invocation from parentType attributes asOrderedCollection.
			tmpClass := invocation from parentType.
			[ tmpClass isInnerClass ] whileTrue: [ tmpClass := tmpClass belongsTo belongsTo.
			possibleAttributes addAll: tmpClass attributes ].
			var := possibleAttributes
				select: [ :attribute | attribute name = param ].
				 ].

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
