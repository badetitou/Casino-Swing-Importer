Class {
	#name : #CSNSwingImporter,
	#superclass : #CSNWebModel,
	#category : #'Casino-Swing-Importer'
}

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
		  :invoc | (self searchWidgetFromAddInvocation: invoc) -> invoc ]) 
		 reject: [ :assocWidgetWithAddInvoc | 
		 assocWidgetWithAddInvoc key isNil ]) do: [ :assocWidgetWithAddInvoc | 
		widget
			addWidget: assocWidgetWithAddInvoc key
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
			| constructorInvoc |
			invoc sender generateFastIfNotDoneAndBind.
			constructorInvoc := invoc fast arguments first famixInvocation.
			widget layout: (self factory createLayoutFor: constructorInvoc withParent: nil) ]
]

{ #category : #private }
CSNSwingImporter >> computeOutgoingAddInvocationForWidget: aWidget [

	| invocations |
	invocations := self computeOutgoingInvocationForWidget: aWidget.
	
	^ invocations select: [ :receivingInvocation | 
		  #( 'add(' 'setViewportView(' 'setContentPane'
		     'setJMenuBar' ) anySatisfy: [ :keyword | 
			  receivingInvocation signature beginsWith: keyword ] ]
]

{ #category : #private }
CSNSwingImporter >> computeOutgoingInvocationForWidget: aWidget [

	| invocations exploreLocalMethod targetMethod |
	invocations := OrderedCollection new.

	targetMethod := (aWidget source signature beginsWith: 'super(')
		                ifTrue: [ "I look at how I am built instead of my super class" 
			                aWidget source sender ]
		                ifFalse: [ aWidget source target first ].
	invocations addAll: targetMethod outgoingInvocations.
	invocations addAll: (targetMethod isConstructor ifTrue: [ 
			 (self retrievedLocalCallFlowOf: targetMethod) flatCollect: [ :method | 
				 method queryAllOutgoingInvocations select: [ :invoc | 
					 invoc receiver isNotNil and: [ 
						 invoc receiver isImplicitVariable ] ] ] ]).
	invocations addAll:
		(targetMethod classes collect: [ :aFamixJavaClass | 
			 aFamixJavaClass queryLocalOutgoing: FamixTInvocation ]) flatten.
	exploreLocalMethod := invocations copy.
	[ exploreLocalMethod isNotEmpty ] whileTrue: [ 
		invocations addAll: ((exploreLocalMethod flatCollect: [ :invoc | 
				  invoc target first outgoingInvocations ]) select: [ :invoc | 
				 aWidget source target first belongsTo = invoc source belongsTo 
					 and: [ 
					 invoc receiver isNil or: [ invoc receiver isImplicitVariable ] ] ]).
		exploreLocalMethod := (exploreLocalMethod flatCollect: [ :invoc | 
			                       invoc target first outgoingInvocations ]) 
			                      select: [ :invoc | 
			                      invoc target first
			                      = aWidget source target first ] ].
	aWidget variable ifNotNil: [ :variable | 
		invocations addAll: variable receivingInvocations ].
	invocations addAll: (invocations
			 select: [ :invoc | invoc signature beginsWith: 'getContentPane' ]
			 thenCollect: [ :invoc | invoc previous ]).
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

{ #category : #api }
CSNSwingImporter >> postImport [
	| currentStep maxStep |
	currentStep := 0.
	maxStep := 3.
	'PostImport'
		displayProgressFrom: 0
		to: maxStep
		during: [ :bar | 
			currentStep := currentStep + 1.
			bar current: currentStep.
			bar label: currentStep printString , '/' , maxStep printString , ' for widgets'.
			self model allCSNWidget do: #postImport displayingProgress: [:wid | 'post import widgets : ', wid name asString ].
			currentStep := currentStep + 1.
			bar current: currentStep.
			bar label: currentStep printString , '/' , maxStep printString , ' for layouts'.
			self model allCSNLayout do: #postImport displayingProgress: [:wid | 'post import layout : ', wid name asString ].
			currentStep := currentStep + 1.
			bar current: currentStep.
			bar label: currentStep printString , '/' , maxStep printString , ' for pages'.
			self model allCSNPage do: #postImport displayingProgress: [:wid | 'post import page : ', wid name asString ].
	]
	
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

{ #category : #api }
CSNSwingImporter >> searchWidgetFromAddInvocation: invocation [

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
		 self completeWidget: widget ] .
	^ widget
]
