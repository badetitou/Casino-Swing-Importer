Extension { #name : #CSNLAlignement }

{ #category : #'*Casino-Swing-Importer' }
CSNLAlignement class >> createAlignementWithBorder: aBorderLayoutString [

	^ aBorderLayoutString = 'BorderLayout.NORTH'
		  ifTrue: [ CSNLNorthAlignement new ]
		  ifFalse: [ 
			  aBorderLayoutString = 'BorderLayout.CENTER'
				  ifTrue: [ CSNLCenterAlignement new ]
				  ifFalse: [ 
					  aBorderLayoutString = 'BorderLayout.SOUTH'
						  ifTrue: [ CSNLSouthAlignement new ]
						  ifFalse: [ nil ] ] ]
]
