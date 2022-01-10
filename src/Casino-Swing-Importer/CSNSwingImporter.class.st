Class {
	#name : #CSNSwingImporter,
	#superclass : #CSNWebModel,
	#category : #'Casino-Swing-Importer'
}

{ #category : #api }
CSNSwingImporter >> completeWidget: widget [

	"add the leaf to the widget"

	widget addAllWidgets:
		(((self computeOutgoingAddInvocationForWidget: widget) collect: [ 
			  :invoc | self searchWidgetFromAddInvocation: invoc ]) reject:
			 #isNil)
]

{ #category : #api }
CSNSwingImporter >> computeOutgoingAddInvocationForWidget: aWidget [

	| invocations exploreLocalMethod |
	invocations := OrderedCollection new.
	invocations addAll: aWidget source target first outgoingInvocations.
	invocations addAll:
		(aWidget source target first isConstructor ifTrue: [ 
			 aWidget source target anyOne queryAllOutgoingInvocations select: [ 
				 :invoc | 
				 invoc receiver isNotNil and: [ invoc receiver isImplicitVariable ] ] ]).
	invocations addAll:
		(aWidget source target first classes collect: [ :aFamixJavaClass | 
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
	
	^ invocations flattened asSet select: [ :receivingInvocation | 
		  #( 'add(' 'setViewportView(' 'setLayout' 'setContentPane'
		     'setJMenuBar' ) anySatisfy: [ :keyword | 
			  receivingInvocation signature beginsWith: keyword ] ] 
]

{ #category : #api }
CSNSwingImporter >> createAllPages [

	(self sourceModel allClasses select: [ :a | a name = 'JFrame' ])
		first withSubclassHierarchy do: [ :jFrameSubclass | 
		(jFrameSubclass methods select: #isConstructor) do: [ :constructor | 
			(constructor incomingInvocations reject: [ :invocation | 
				 invocation source name = 'main' and: [ 
					 invocation source parentType name ~= 'Main' ] ]) do: [ 
				:invocation | self factory createPageFromInvocation: invocation ] ] ].
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
		widget isContainer ifTrue: [ self completeWidget: widget ] ].
	^ widget
]
