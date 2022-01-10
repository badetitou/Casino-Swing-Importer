# Casino-Swing-Importer

## Installation

```st
Metacello new
  githubUser: 'badetitou' project: 'Casino-Swing-Importer' commitish: 'v2' path: 'src';
  baseline: 'CasinoSwingImporter';
  load
```

## Usage

1. Import a FamixJavaModel
2. Create a Casino Importer
3. Extract the UI code in a Casino Model

```
rca := MooseModel root at: 1.
rca rootFolder: 'D:\Developpement\mse\VerveineJ'.

swingModel := CSNUICWModel new name: 'RestSuiteUI'; yourself.

swingImporter := CSNSwingImporter new.

swingImporter
	sourceModel: rca;
	createModelIn: swingModel.

swingModel
```
