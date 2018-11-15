"
mooseModel := MooseModel importFromMSEStream: 'D:\Developpement\mse\rcaexplore\verveinej\rca.mse' asFileReference readStream.
mooseModel rootFolder: 'D:\Developpement\mse\rcaexplore\rcaexplore'.
MooseModel resetRoot.

swingModel := MooseModel new.
CSNSwingImporter new sourceModel: mooseModel; createModelIn: swingModel.
swingModel name: 'RCA'.
swingModel.
"
Class {
	#name : #ManifestCSNSwingFactory,
	#superclass : #PackageManifest,
	#category : #'Casino-Swing-Importer'
}
