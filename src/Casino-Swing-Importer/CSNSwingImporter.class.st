Class {
	#name : #CSNSwingImporter,
	#superclass : #CSNWebModel,
	#category : #'Casino-Swing-Importer'
}

{ #category : #api }
CSNSwingImporter >> completeWidget: widget [
	"add the leaf to the widget"
	widget
		addAllWidgets:
			(((self computeOutgoingAddInvocationForWidget: widget)
				collect: [ :invoc | self searchWidgetFromAddInvocation: invoc ]) reject: #isNil)

	"widget
		addAllWidgets:
			((widget variable receivingInvocations
				select: [ :invoc | 
					#('add(' 'setViewportView(')
						anySatisfy: [ :addMethodString | invoc signature beginsWith: addMethodString ] ]
				thenCollect: [ :invoc | self searchWidgetFromAddInvocation: invoc ]) reject: #isNil)"
]

{ #category : #api }
CSNSwingImporter >> computeOutgoingAddInvocationForWidget: aWidget [
	| invocations exploreLocalMethod |
	invocations := OrderedCollection new.
	invocations addAll: aWidget source to first outgoingInvocations.
	invocations addAll: (aWidget source to first classes collect: #outgoingInvocations) flatten.
	exploreLocalMethod := invocations copy.
	[ exploreLocalMethod isNotEmpty ]
		whileTrue: [ invocations
				addAll:
					((exploreLocalMethod flatCollect: [ :invoc | invoc to first outgoingInvocations ]) select:
					[ :invoc |  aWidget source to first belongsTo = invoc from belongsTo and: [ invoc receiver isNil or: [ invoc receiver isImplicitVariable ] ] ]).
			exploreLocalMethod := (exploreLocalMethod
				flatCollect: [ :invoc | invoc to first outgoingInvocations ])
				select:
					[ :invoc | invoc to first = aWidget source to first ] ].
	aWidget variable
		ifNotNil: [ :variable | invocations addAll: variable receivingInvocations ].
	^ invocations flattened
		select: [ :receivingInvocation | 
			#('add(' 'setViewportView(' 'setContentPane' 'setJMenuBar')
				anySatisfy: [ :keyword | receivingInvocation signature beginsWith: keyword ] ]
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
	self completeWidget: aPage
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
	listOfinvocation := (var incomingAccesses select: #isWrite)
		flatCollect: [ :access | 
			access from outgoingInvocations
				select: [ :invoc | 
					access sourceAnchor startPos < invoc sourceAnchor startPos
						and:
							[ access sourceAnchor endPos + 5 > invoc sourceAnchor startPos ] ] ].
	"If attribute, check if the instaciation is made directly and not inside the constructor"
	(listOfinvocation isEmpty and: [ var isAttribute ])
		ifTrue: [ listOfinvocation := (var parentType outgoingInvocations
				select: [ :invoc | 
					invoc from isInstanciationInitializer
						and: [ var sourceAnchor startPos < invoc sourceAnchor startPos
								and:
									[ var sourceAnchor endPos + 5 > invoc sourceAnchor startPos ] ] ])
				asOrderedCollection ].
	"We don't have access to the write accesses... so we try to find directly inside the method"
	listOfinvocation
		ifEmpty: [ listOfinvocation := var parentBehaviouralEntity outgoingInvocations
				select: [ :invoc | 
					var sourceAnchor startPos < invoc sourceAnchor startPos
						and:
							[ var sourceAnchor endPos + 5 > invoc sourceAnchor startPos ] ] ].
	listOfinvocation ifEmpty: [ ^ nil ] ifNotEmpty: [ ^ (listOfinvocation select: [ :invoc | invoc to first isConstructor ]) first ]
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
		ifEmpty: [ | possibleAttributes tmpClass |
			possibleAttributes := invocation from parentType attributes asOrderedCollection.
			tmpClass := invocation from parentType.
			[ tmpClass isInnerClass ]
				whileTrue: [ tmpClass := tmpClass belongsTo belongsTo.
					possibleAttributes addAll: tmpClass attributes ].
			var := possibleAttributes select: [ :attribute | attribute name = param ] ].
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
