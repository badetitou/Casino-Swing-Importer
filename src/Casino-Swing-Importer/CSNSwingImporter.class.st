Class {
	#name : #CSNSwingImporter,
	#superclass : #CSNWebModel,
	#instVars : [
		'possibleAddInvocationVisitor',
		'possibleAddInvocationVisitorClass',
		'addWidgetVisitor',
		'possibleAddWidgetVisitorClass'
	],
	#category : #'Casino-Swing-Importer'
}

{ #category : #accessing }
CSNSwingImporter >> addWidgetVisitorClass [

	^ possibleAddWidgetVisitorClass ifNil: [ 
		  possibleAddWidgetVisitorClass := CSNSwingAddWidgetVisitor ]
]

{ #category : #api }
CSNSwingImporter >> completeWidget: widget [

	"add the leaf to the widget"

	self computeLayoutOf: widget.
	self computeChildrenOf: widget.
	self computeActionsOf: widget.
]

{ #category : #private }
CSNSwingImporter >> computeActionsOf: widget [

	| invocations addActionsListenersInvocations |
	invocations := self computeOutgoingInvocationForWidget: widget.
	addActionsListenersInvocations := invocations select: [ 
		                                  :receivingInvocation | 
		                                  #( 'addActionListener' ) 
			                                  anySatisfy: [ :keyword | 
			                                  receivingInvocation signature 
				                                  beginsWith: keyword ] ].
	addActionsListenersInvocations do: [ :addActionsListenersInvocation | 
		| invocationArgument listenerClass methodCalled |
		addActionsListenersInvocation sender generateFastIfNotDoneAndBind.
		invocationArgument := addActionsListenersInvocation fast arguments
			                      anyOne.
		invocationArgument name = 'this' ifTrue: [ 
			listenerClass := (addActionsListenersInvocation sender atScope:
				                  FamixTClass) anyOne ].
		(invocationArgument isKindOf: FASTJavaNewClassExpression) ifTrue: [ 
			listenerClass := invocationArgument famixType ].
		(invocationArgument isKindOf: FASTJavaOuterThis) ifTrue: [ 
			listenerClass := self sourceModel allModelClasses detect: [ :class | 
				                 class name = invocationArgument type name ] ].
		listenerClass
			ifNil: [ ('Not Found for ' , invocationArgument name) record ]
			ifNotNil: [ 
				methodCalled := listenerClass methods
					                detect: [ :method | 
					                method name = 'actionPerformed' ]
					                ifNone: [ 
						                ('Not found for ' , listenerClass name) record.
						                ^ nil ].
				widget addAction: ((self factory create: CSNBOnClick)
						 addBehavior: (methodCalled
								  generateFastIfNotDoneAndBind;
								  fast);
						 yourself).
				methodCalled := listenerClass ] ]
]

{ #category : #private }
CSNSwingImporter >> computeChildrenOf: widget [

	(((self computeOutgoingAddInvocationForWidget: widget) collect: [ 
		  :invoc | 
		  (self searchWidgetFromAddInvocation: invoc for: widget) -> invoc ]) 
		 reject: [ :assocWidgetWithAddInvoc | 
		 assocWidgetWithAddInvoc key isNil ]) do: [ :assocWidgetWithAddInvoc | 
		| widgetToAdd |
		widgetToAdd := assocWidgetWithAddInvoc key widgetContainer
			               ifNotNil: [ 
				               | copy |
				               copy := assocWidgetWithAddInvoc key
					                       verticalVeryDeepCopy.
				               (copy recursiveWidgets , { copy }) flattened
					               select: [ :wid | 
					               wid isContainer and: [ wid children isEmpty ] ]
					               thenDo: [ :wid | 
						               self
							               execute: [ self computeChildrenOf: wid ]
							               recordedAs:
								               (String streamContents: [ :stream | 
									                stream << 'Compute child: '
									                << wid printString << ' of '
									                << assocWidgetWithAddInvoc key printString ]) ].
				               copy ]
			               ifNil: [ assocWidgetWithAddInvoc key ].
		self addWidgetVisitorClass
			addWidget: widgetToAdd
			to: widget
			withInvocationOfAdd: assocWidgetWithAddInvoc value
			usingFactory: self factory ]
]

{ #category : #private }
CSNSwingImporter >> computeLayoutOf: widget [

	| invocations |
	invocations := self computeOutgoingInvocationForWidget: widget.

	invocations
		select: [ :receivingInvocation | 
			#( 'setLayout' ) anySatisfy: [ :keyword | 
				receivingInvocation signature beginsWith: keyword ] ]
		thenDo: [ :invoc | 
			| constructorInvoc argument |
			invoc sender generateFastIfNotDoneAndBind.
			argument := invoc fast arguments first.
			constructorInvoc := argument famixInvocation ifNil: [ 
				                    argument famixVariable
					                    ifNotNil: [ :famixVariable | 
					                    famixVariable declaredType ]
					                    ifNil: [ nil ] ].
			constructorInvoc ifNotNil: [ 
				widget layout:
					(self factory createLayoutFor: constructorInvoc withParent: nil) ] ]
]

{ #category : #private }
CSNSwingImporter >> computeOutgoingAddInvocationForWidget: aWidget [

	| invocations |
	invocations := self computeOutgoingInvocationForWidget: aWidget.
	^ (invocations select: [ :receivingInvocation | 
		   (receivingInvocation sender parentType = aWidget realClass or: [ 
			    aWidget sources anySatisfy: [ :source | 
				    source isInvocation not or: [ 
					    source sender parentType
					    = receivingInvocation sender parentType ] ] ]) and: [ 
			   (self possibleAddInvocationVisitor visit: aWidget) anySatisfy: [ 
				   :keyword | receivingInvocation signature beginsWith: keyword ] ] ])
		  asSet
]

{ #category : #private }
CSNSwingImporter >> computeOutgoingInvocationForWidget: aWidget [

	| invocations exploreLocalMethod targetMethod |
	invocations := OrderedCollection new.

	targetMethod := (aWidget source class usesTrait: FamixTMethod)
		                ifTrue: [ aWidget source ]
		                ifFalse: [ 
			                (aWidget source class usesTrait: FamixTParameter)
				                ifTrue: [ aWidget source parentBehaviouralEntity ]
				                ifFalse: [ 
					                (aWidget source signature beginsWith: 'super(')
						                ifTrue: [ "I look at how I am built instead of my super class" 
							                aWidget source sender ]
						                ifFalse: [ aWidget source target first ] ] ].
	invocations addAll: targetMethod outgoingInvocations.
	targetMethod isConstructor ifTrue: [ "I might understand stuff based of parameters of the invocations of the constructor"
		(aWidget source isKindOf: FamixJavaInvocation) ifTrue: [ 
			invocations add: aWidget source ].
		invocations addAll:
			((self retrievedLocalCallFlowOf: targetMethod) flatCollect: [ 
				 :method | 
				 method queryAllOutgoingInvocations select: [ :invoc | 
					 invoc receiver isNotNil  ] ]) ].
	invocations addAll:
		(targetMethod classes collect: [ :aFamixJavaClass | 
			 aFamixJavaClass queryLocalOutgoing: FamixTInvocation ]) flatten.
	exploreLocalMethod := invocations copy.
	[ exploreLocalMethod isNotEmpty ] whileTrue: [ 
		invocations addAll: ((exploreLocalMethod flatCollect: [ :invoc | 
				  invoc target first outgoingInvocations ]) select: [ :invoc | 
				 targetMethod belongsTo = invoc source belongsTo and: [ 
					 invoc receiver isNil or: [ invoc receiver isImplicitVariable ] ] ]).
		exploreLocalMethod := (exploreLocalMethod flatCollect: [ :invoc | 
			                       invoc target first outgoingInvocations ]) 
			                      select: [ :invoc | 
			                      invoc target first = targetMethod ] ].
	(self isWidgetReturned: aWidget) ifTrue: [ 
		(aWidget source sender incomingInvocations
			 collect: #affectation
			 thenSelect: #isNotNil) do: [ :variableOfMethodThatCallMe | 
			invocations addAll: variableOfMethodThatCallMe receivingInvocations ] ]. "Test if the variable is returned"
	aWidget variable ifNotNil: [ :variable | 
		invocations addAll: variable receivingInvocations ].

	invocations
		select: [ :invoc | invoc signature beginsWith: 'getContentPane' ]
		thenDo: [ :invoc | 
			invoc generateFastIfNotDoneAndBind.
			(invoc fast receiverOwner isKindOf: FASTJavaMethodInvocation) 
				ifTrue: [ 
				invocations add: invoc fast receiverOwner famixInvocation ] ].
	^ invocations flattened asSet
]

{ #category : #api }
CSNSwingImporter >> createAllPages [

	(self sourceModel allClasses select: [ :a | a name = 'JFrame' ])
		first withSubclassHierarchy do: [ :jFrameSubclass | 
		(jFrameSubclass methods select: #isConstructor) do: [ :constructor | 
			(constructor incomingInvocations reject: [ :invocation | 
				 (invocation source name = 'main' and: [ 
					  invocation source parentType name ~= 'Main' ]) or: [ 
					 invocation container isNotNil and: [ 
						 invocation container signature beginsWith: 'showOpenDialog' ] ] ]) 
				do: [ :invocation | 
				self factory createPageFromInvocation: invocation ] ] ].
	^ self model
]

{ #category : #accessing }
CSNSwingImporter >> createFactory [

	factory := CSNSwingFactory new
		           model: model;
		           importer: self;
					  addVisitorImporter: CSNSwingModelImporterVisitor new;
		           yourself
]

{ #category : #api }
CSNSwingImporter >> generatePage: aPage [
	self completeWidget: aPage
]

{ #category : #api }
CSNSwingImporter >> generateWidgets [

	self model allCSNPage do: [ :page | self generatePage: page ]
]

{ #category : #api }
CSNSwingImporter >> import [
	self createAllPages.
	self generateWidgets
]

{ #category : #private }
CSNSwingImporter >> isWidgetReturned: aWidget [

	^ (aWidget variable isNotNil and: [ 
		   aWidget variable fastAccesses anySatisfy: [ :access | "Test if the variable is returned"
			   (access atAnyScope: { 
					    FASTJavaReturnStatement.
					    FASTJavaClassDeclaration.
					    FASTTBehaviouralEntity }) anyOne isKindOf:
				   FASTJavaReturnStatement ] ]) or: [ 
		  (aWidget source isKindOf: FamixJavaInvocation) and: [ 
			  aWidget source isReturned ] ]
]

{ #category : #accessing }
CSNSwingImporter >> possibleAddInvocationVisitor [

	^ possibleAddInvocationVisitor
]

{ #category : #accessing }
CSNSwingImporter >> possibleAddInvocationVisitor: anObject [

	possibleAddInvocationVisitor := anObject
]

{ #category : #accessing }
CSNSwingImporter >> possibleAddInvocationVisitorClass [

	^ possibleAddInvocationVisitorClass ifNil: [ 
		  possibleAddInvocationVisitorClass := CSNSwingPossibleAddInvocationVisitor ]
]

{ #category : #accessing }
CSNSwingImporter >> possibleAddInvocationVisitorClass: anObject [

	^ possibleAddInvocationVisitorClass := anObject
]

{ #category : #api }
CSNSwingImporter >> postImport [

	self
		execute: [ self model allCSNWidget do: #postImport ]
		recordedAs: 'Post import widgets'.
	self
		execute: [ self model allCSNLayout do: #postImport ]
		recordedAs: 'Post import layouts'.
	self
		execute: [ self model allCSNPage do: #postImport ]
		recordedAs: 'Post import pages'
]

{ #category : #accessing }
CSNSwingImporter >> preImport [
	super preImport.
	possibleAddInvocationVisitor := self possibleAddInvocationVisitorClass new.
	addWidgetVisitor := self addWidgetVisitorClass	 new
]

{ #category : #'as yet unclassified' }
CSNSwingImporter >> retrievedLocalCallFlowOf: aFamixJavaMethod [

	| methods currentSize |
	methods := Set new.
	methods add: aFamixJavaMethod.
	[ currentSize ~= methods size ] whileTrue: [ 
		currentSize := methods size.
		methods addAll: (methods flatCollect: [ :method | 
				 method queryAllOutgoingInvocations
					 collect: [ :invoc | invoc target anyOne ]
					 thenSelect: [ :invoc | 
					 invoc parentType = aFamixJavaMethod parentType ] ]) ].
	^ methods
]

{ #category : #api }
CSNSwingImporter >> searchInstatiateVariable: var [

	| listOfinvocation |
	listOfinvocation := (var incomingAccesses select: #isWrite) 
		                    flatCollect: [ :access | 
			                    access source outgoingInvocations select: [ 
				                    :invoc | 
				                    access sourceAnchor startPos
				                    < invoc sourceAnchor startPos and: [ 
					                    access sourceAnchor endPos + 5
					                    > invoc sourceAnchor startPos ] ] ].
	"If attribute, check if the instaciation is made directly and not inside the constructor"
	(listOfinvocation isEmpty and: [ var isAttribute ]) ifTrue: [ 
		listOfinvocation := (var parentType outgoingInvocations select: [ 
			                     :invoc | 
			                     invoc from isInstanciationInitializer and: [ 
				                     var sourceAnchor startPos
				                     < invoc sourceAnchor startPos and: [ 
					                     var sourceAnchor endPos + 5
					                     > invoc sourceAnchor startPos ] ] ])
			                    asOrderedCollection ].
	"We don't have access to the write accesses... so we try to find directly inside the method"
	listOfinvocation ifEmpty: [ 
		listOfinvocation := var parentBehaviouralEntity outgoingInvocations 
			                    select: [ :invoc | 
				                    var sourceAnchor startPos
				                    < invoc sourceAnchor startPos and: [ 
					                    var sourceAnchor endPos + 5
					                    > invoc sourceAnchor startPos ] ] ].
	listOfinvocation ifEmpty: [ ^ nil ] ifNotEmpty: [ 
		^ (listOfinvocation select: [ :invoc | 
			   invoc target first isConstructor ]) first ]
]

{ #category : #'private - actions' }
CSNSwingImporter >> searchWidgetFromAddInvocation: invocation for: widget2 [

	"search the widget added "

	| param var widget |
	param := invocation parameters
		         at: 1
		         ifAbsent: [ 
		         Exception signal: 'no parameter to find the added widget' ].
	var := invocation source localVariables select: [ :variable | 
		       variable name = param ].
	var ifEmpty: [ 
		| possibleAttributes tmpClass |
		possibleAttributes := invocation source parentType attributes
			                      asOrderedCollection.
		tmpClass := invocation source parentType.
		[ tmpClass isInnerClass ] whileTrue: [ 
			tmpClass := (tmpClass typeContainer atScope: FamixTClass) anyOne.
			possibleAttributes addAll: tmpClass attributes ].
		var := possibleAttributes select: [ :attribute | 
			       attribute name = param ] ].
	var ifNotEmpty: [ "the added widget is a variable from somewhere else"
		| instanciationInvoc |
		instanciationInvoc := self searchInstatiateVariable: var first.
		instanciationInvoc ifNil: [ ^ nil ].
		widget := self factory createWidgetFromSwingInvocation:
			          instanciationInvoc.
		self completeWidget: widget ].
	^ widget
]
