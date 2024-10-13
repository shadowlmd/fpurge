unit fp_Cfg;

{$MODE objfpc}

interface

uses
	Objects,
	fp_Misc,
	fp_Vars,
	CfgParser;

procedure ParseCfg;

implementation

procedure GetValue(const name: string; vt: byte; var value);
begin
	case vt of
		vtStr:
			if not CfgGetKeyValue(conf, name, ' ', vt, string(value))
			then Info('Warning: ' + CfgLastError);

		vtInt:
			if not CfgGetKeyValue(conf, name, ' ', vt, integer(value))
			then Info('Warning: ' + CfgLastError);

		vtBool:
			if not CfgGetKeyValue(conf, name, ' ', vt, boolean(value))
			then Info('Warning: ' + CfgLastError);
	end;
end;

procedure ParseCfg;

begin
	conf := New(PStringCollection, Init(10, 10));
	conf^.Duplicates := true;

	Info('Reading ' + CfgName);
	if not CfgLoad(conf, CfgName, ';', false) then
	begin
		Info('Error: ' + CfgLastError);
		exit;
	end;

	GetValue('PURGELIST', vtStr, PurgeList);
	GetValue('ARCHIVEPATH', vtStr, ArchivePath);
	GetValue('ROOTDIRSLIST', vtStr, RootDirsList);
	GetValue('KILLFILES', vtBool, KillFiles);
	GetValue('DEFAGE', vtInt, DefAge);

	// необязательные параметры. никаких ворнингов.
	CfgGetKeyValue(conf, 'LOGNAME', ' ', vtStr, LogName);
	CfgGetKeyValue(conf, 'EXCLUDELIST', ' ', vtStr, ExcludeList);
	Info('Done');

	Dispose(conf, Done);
end;

end.
