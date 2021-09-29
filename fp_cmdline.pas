unit fp_CmdLine;

{$MODE objfpc}

interface

uses
	fp_Vars;

procedure ParseCmdLine;
procedure DisplayHelp;

implementation

procedure DisplayHelp;
begin
	WriteLn(version);
	WriteLn;
	WriteLn('Usage: ' + ParamStr(0) + ' [-c config] [-p] [-s] [-q]');
	WriteLn('       -s scan mode');
	WriteLn('       -p purge mode');
	WriteLn('       -q be quiet');
	WriteLn('       -? this message');
	Halt(1);
end;

procedure ParseCmdLine;
var
	i: byte;
begin
	if ParamCount = 0 then
		DisplayHelp;

	for i := 1 to ParamCount do
	begin
		if not (ParamStr(i)[1] in ['-', '/']) then continue;
		case UpCase(ParamStr(i)[2]) of
			'C'        : CfgName := ParamStr(i+1);
			'Q'        : Quiet := true;
			'S'        : ScanMode := true;
			'P'        : PurgeMode := true;
			'?', 'H'   : DisplayHelp;
		end;
	end;
end;

end.
