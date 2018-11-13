Class {
	#name : #CSNSwingImporter,
	#superclass : #BLWebModel,
	#category : #'Casino-Swing-Importer'
}

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
				thenCollect: [ :invocation | self searchWidgetFromAddInvocation: invocation ] ]
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
	var.
	self halt
]

{ #category : #api }
CSNSwingImporter >> searchWidgetFromAddInvocation: invocation [
	"search the widget added "
	| param var widget | 
	param := invocation parameters at: 1 ifAbsent: [ Exception signal: 'no parameter to find the added widget' ].
	var := invocation from localVariables select: [ :variable | variable name = param ].
	var ifEmpty: [ var := invocation from parentType attributes select: [ :attribute | attribute name = param ] ].
	var ifNotEmpty: [ "the added widget is a variable from somewhere else"
		self searchInstatiateVariable: var first.
		var .self halt.  ].
	^ widget
	
]
