Class {
	#name : #CSNSwingDefaultChildrenWidgetsFromInvocationOfWidgetVisitor,
	#superclass : #CSNModelVisitor,
	#instVars : [
		'invocation',
		'factory'
	],
	#category : #'Casino-Swing-Importer'
}

{ #category : #'as yet unclassified' }
CSNSwingDefaultChildrenWidgetsFromInvocationOfWidgetVisitor >> defaultChildFrom: aFamixJavaInvocation for: aWidget [

	^ self
		  invocation: aFamixJavaInvocation;
		  visit: aWidget
]

{ #category : #accessing }
CSNSwingDefaultChildrenWidgetsFromInvocationOfWidgetVisitor >> factory [

	^ factory
]

{ #category : #accessing }
CSNSwingDefaultChildrenWidgetsFromInvocationOfWidgetVisitor >> factory: anObject [

	factory := anObject
]

{ #category : #accessing }
CSNSwingDefaultChildrenWidgetsFromInvocationOfWidgetVisitor >> invocation [

	^ invocation
]

{ #category : #accessing }
CSNSwingDefaultChildrenWidgetsFromInvocationOfWidgetVisitor >> invocation: anObject [

	invocation := anObject
]

{ #category : #accessing }
CSNSwingDefaultChildrenWidgetsFromInvocationOfWidgetVisitor >> visitCSNOriginedEntity: aCSNOriginedEntity [

	^ { } asOrderedCollection
]
