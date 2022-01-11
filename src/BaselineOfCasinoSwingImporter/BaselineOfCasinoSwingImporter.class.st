Class {
	#name : #BaselineOfCasinoSwingImporter,
	#superclass : #BaselineOf,
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
		baseline: 'Casino'
		with: [ spec
				loads: 'behavior-bl';
				repository: 'github://badetitou/Casino:v2/src' ]
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
		package: 'Casino-Swing-Importer' with: [ spec requires: #('Casino') ]
]
