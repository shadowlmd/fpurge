unit fp_Vars;

{$MODE objfpc}

interface

uses
	Objects;

const
	version                   = 'FPurge 0.33 (C) 2024 Alexey Fayans, 2:5030/1997';

	CfgName        : string   = 'fpurge.cfg';
	PurgeList      : string   = 'fpurge.lst';
	ExcludeList    : string   = '';
	LogName        : string   = '';
	ArchivePath    : string   = '';
	RootDirsList   : string   = '';
	DefAge         : integer  = 0;
	KillFiles      : boolean  = true;
	Quiet          : boolean  = false;
	ScanMode       : boolean  = false;
	PurgeMode      : boolean  = false;

var
	conf,
	ExcludeNames,
	RootDirs,
	PurgeDirs      : PStringCollection;

implementation

end.
