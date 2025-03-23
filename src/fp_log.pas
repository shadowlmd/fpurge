unit fp_Log;

{$I-}
{$MODE objfpc}

interface

uses
  Dos,
  fp_Vars,
  fp_Misc;

procedure LogOpen;
procedure LogClose;
procedure LogWriteLn(const s: string);

implementation

var
  LogFile: text;
  logging: boolean;

function Now: string;
var
  Year, Month,Day,
  Hour, Min, Sec, tmp : word;

function L0(const i: word): string;
var
  s: string;
begin
  Str(i, s);
  if i < 10 then
    result := '0' + s
  else
    result := s;
end;

begin
  GetDate(Year, Month, Day, tmp);
  GetTime(Hour, Min, Sec, tmp);
  result := L0(Year)+'-'+L0(Month)+'-'+L0(Day)+' '+L0(Hour)+':'+L0(Min)+':'+L0(Sec);
end;

procedure LogOpen;
begin
  if Length(LogName) = 0 then
  begin
    logging := false;
    exit;
  end;

  assign(LogFile, LogName);
  append(LogFile);
  if ioresult <> 0 then
  begin
    rewrite(LogFile);
    if ioresult <> 0 then
    begin
      logging := false;
      Info('Warning: unable to open "' + LogName + '" for writing');
      exit;
    end;
  end;

  logging := true;
  WriteLn(LogFile);
  WriteLn(LogFile, '*** ' + Now + ' log opened');
end;

procedure LogClose;
begin
  if not logging then exit;

  WriteLn(LogFile, '*** ' + Now + ' log closed');
  Close(LogFile);
end;

procedure LogWriteLn(const s: string);
begin
  Info(s);
  if logging then
    WriteLn(LogFile, s);
end;

end.
