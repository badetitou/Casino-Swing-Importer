Class {
	#name : #BaselineOfCasinoSwingImporter,
	#superclass : #Object,
	#category : #BaselineOfCasinoSwingImporter
}

{ #category : #baselines }
BaselineOfCasinoSwingImporter >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ self defineDependencies: spec.
			self definePackages: spec.
			self defineGroups: spec ]
]

{ #category : #baselines }
BaselineOfCasinoSwingImporter >> defineDependencies: spec [
	spec
		baseline: 'BLToolkit'
		with: [ spec
				loads: 'core-extented';
				repository: 'github://badetitou/BL-Toolkit:master/src' ]
]

{ #category : #baselines }
BaselineOfCasinoSwingImporter >> defineGroups: spec [
	spec group: 'default' with: #('Casino-Swing-Importer')
]

{ #category : #baselines }
BaselineOfCasinoSwingImporter >> definePackages: spec [
	spec
		repository: 'https://github.com/badetitou/Casino-Swing-Importer';
		package: 'BaselineOfCasinoSwingImporter';
		package: 'Casino-Swing-Importer' with: [ spec requires: #('BLToolkit') ]
]
