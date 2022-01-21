Class {
	#name : #CSNSwingModelImporterVisitor,
	#superclass : #CSNModelImporterVisitor,
	#category : #'Casino-Swing-Importer'
}

{ #category : #visiting }
CSNSwingModelImporterVisitor >> createWidget: aWidgetClass [

	| createdInstance |
	createdInstance := (self create: aWidgetClass)
		                   realClass: source invokedClass;
		                   addSource: source;
		                   yourself.
	"test position for layout"
	^ createdInstance
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNLBorderLayout: aCSNLBorderLayout [

	^ 'BorderLayout' = source invokedClassName
		  ifTrue: [ self create: CSNLBorderLayout ]
		  ifFalse: [ nil ]
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNUIButton: aCSNUIButton [

	^ 'JButton' = source invokedClassName
		  ifTrue: [ 
			  (self createWidget: aCSNUIButton)
				  addAttribute: ((self create: CSNUILabel) attributeValue:
							   (source parameters at: 1 ifAbsent: [ '' ]));
				  yourself ]
		  ifFalse: [ nil ]
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNUIFieldset: aCSNUIFieldset [

	^ nil
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNUIInputCheckbox: aCSNUIInputCheckbox [

	^ 'JCheckBox' = source invokedClassName
		  ifTrue: [ self createWidget: aCSNUIInputCheckbox ]
		  ifFalse: [ nil ]
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNUIInputEmail: aCSNUIInputEmail [

	^ nil
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNUIInputFile: aCSNUIInputFile [

	^ 'JFileChooser' = source invokedClassName
		  ifTrue: [ self createWidget: aCSNUIInputFile ]
		  ifFalse: [ nil ]
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNUIInputNumber: aCSNUIInputNumber [

	^ 'JSpinner' = source invokedClassName
		  ifTrue: [ self createWidget: aCSNUIInputNumber ]
		  ifFalse: [ nil ]
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNUIInputPassword: aCSNUIInputPassword [

	^ nil
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNUIInputText: aCSNUIInputText [

	^ 'JTextField' = source invokedClassName
		  ifTrue: [ self createWidget: aCSNUIInputText ]
		  ifFalse: [ nil ]
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNUIMenu: aCSNUIMenu [

	^ 'JMenu' = source invokedClassName
		  ifTrue: [ 
			  (self createWidget: aCSNUIMenu)
				  addAttribute: ((self create: CSNUILabel) attributeValue:
							   (source parameters at: 1 ifAbsent: [ '' ]));
				  yourself ]
		  ifFalse: [ nil ]
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNUIMenuItem: aCSNUIMenuItem [

	^ 'JMenuItem' = source invokedClassName
		  ifTrue: [ 
			  (self createWidget: aCSNUIMenuItem)
				  addAttribute: ((self create: CSNUILabel) attributeValue:
							   (source parameters at: 1 ifAbsent: [ '' ]));
				  yourself ]
		  ifFalse: [ nil ]
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNUIPanel: aCSNUIPanel [

	^ (#( 'JPanel' 'JScrollPane' ) includesAny:
		   (source invokedClass withSuperclassHierarchy collect:
			    #invokedClassName))
		  ifTrue: [ self createWidget: aCSNUIPanel ]
		  ifFalse: [ nil ]
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNUIParagraph: aCSNUIParagraph [

	^ 'JLabel' = source invokedClassName
		  ifTrue: [ 
			  (self createWidget: aCSNUIParagraph)
				  addAttribute: ((self create: CSNUILabel) attributeValue:
							   (source parameters at: 1 ifAbsent: [ '' ]));
				  yourself ]
		  ifFalse: [ nil ]
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNUISelect: aCSNUISelect [

	^ 'JComboBox' = source invokedClassName
		  ifTrue: [ self createWidget: aCSNUISelect ]
		  ifFalse: [ nil ]
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNUITabManager: aCSNUITabManager [

	^ 'JTabbedPane' = source invokedClassName
		  ifTrue: [ self createWidget: aCSNUITabManager ]
		  ifFalse: [ nil ]
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNUITextarea: aCSNUITextarea [
	
	^ 'JTextArea' = source invokedClassName
		  ifTrue: [ self createWidget: aCSNUITextarea ]
		  ifFalse: [ nil ]
]

{ #category : #visiting }
CSNSwingModelImporterVisitor >> visitCSNUIUnorderedList: aCSNUIUnorderedList [

	^ 'JList' = source invokedClassName
		  ifTrue: [ self createWidget: aCSNUIUnorderedList ]
		  ifFalse: [ nil ]
]
