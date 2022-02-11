"
This visitor hold the command to add a widget inside another (for the hierarchy).

First, set the attributes of the command: `widgetToAdd`, `sourceInvocation`, and `factory`.
Then, visit the container.
"
Class {
	#name : #CSNSwingAddWidgetVisitor,
	#superclass : #CSNModelVisitor,
	#instVars : [
		'widgetToAdd',
		'sourceInvocation',
		'factory'
	],
	#category : #'Casino-Swing-Importer'
}

{ #category : #adding }
CSNSwingAddWidgetVisitor class >> addWidget: widgetToAdd to: aWidget withInvocationOfAdd: sourceInvocation usingFactory: aFactory [

	^ self new
		  widgetToAdd: widgetToAdd;
		  sourceInvocation: sourceInvocation;
		  factory: aFactory;
		  visit: aWidget
]

{ #category : #accessing }
CSNSwingAddWidgetVisitor >> addWidget: aWidgetToAdd to: aWidget withInvocationOfAdd: aSourceInvocation usingFactory: aFactory [

	^ self
		  widgetToAdd: aWidgetToAdd;
		  sourceInvocation: aSourceInvocation;
		  factory: aFactory;
		  visit: aWidget
]

{ #category : #accessing }
CSNSwingAddWidgetVisitor >> factory [

	^ factory
]

{ #category : #accessing }
CSNSwingAddWidgetVisitor >> factory: anObject [

	factory := anObject
]

{ #category : #accessing }
CSNSwingAddWidgetVisitor >> sourceInvocation [

	^ sourceInvocation
]

{ #category : #accessing }
CSNSwingAddWidgetVisitor >> sourceInvocation: anObject [

	sourceInvocation := anObject
]

{ #category : #visiting }
CSNSwingAddWidgetVisitor >> visitCSNWidget: aCSNWidget [

	^ aCSNWidget
		addWidget: self widgetToAdd
		withInvocationOfAdd: self sourceInvocation
		usingFactory: self factory
]

{ #category : #accessing }
CSNSwingAddWidgetVisitor >> widgetToAdd [

	^ widgetToAdd
]

{ #category : #accessing }
CSNSwingAddWidgetVisitor >> widgetToAdd: anObject [

	widgetToAdd := anObject
]
