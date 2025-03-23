unit fp_Purge;

{$MODE objfpc}

interface

uses
  Objects,
  Dos,
  CfgParser,
  DateDiff,
  fp_Misc,
  fp_Log,
  fp_Vars;

function InitPurgeDirs: boolean;
procedure FreePurgeDirs;
procedure Purge;

implementation

function InitPurgeDirs: boolean;
begin
  if Length(PurgeList) = 0 then
  begin
    Info('Error: PurgeList is not defined');
    result := false;
    exit;
  end;

  PurgeDirs := New(PStringCollection, Init(20, 10));
  PurgeDirs^.Duplicates := true;
  Info('Reading ' + PurgeList);
  if not CfgLoad(PurgeDirs, PurgeList, ';', false) then
  begin
    Info('Error: ' + CfgLastError);
    result := false;
    exit;
  end;
  Info('Done');
  result := true;
end;

procedure FreePurgeDirs;
begin
  Dispose(PurgeDirs, Done);
end;

procedure InitExcludeNames;
begin
  if Length(ExcludeList) = 0 then exit;

  ExcludeNames := New(PStringCollection, Init(5, 5));
  ExcludeNames^.Duplicates := true;
  Info('Reading ' + ExcludeList);
  if not CfgLoad(ExcludeNames, ExcludeList, ';', true) then
  begin
    Info('Error: ' + CfgLastError);
    exit;
  end;
  Info('Done');
end;

procedure FreeExcludeNames;
begin
  if Length(ExcludeList) = 0 then exit;

  Dispose(ExcludeNames, Done);
end;

function InExcludeList(const Name: string): boolean;
var
  found: boolean;

  function MatchExcludeName(ps: pstring): boolean;
  begin
    if IsWildCard(pstring(ps)^) then
    begin
      if CheckWildCard(Name, pstring(ps)^) then
        found := true;
    end else
    begin
      if Name = pstring(ps)^ then
        found := true;
    end;
    result := found;
  end;

begin
  if (Length(ExcludeList) = 0) or (ExcludeNames^.Count = 0) then
    result := false
  else
  begin
    found := false;
    ExcludeNames^.FirstThat(@MatchExcludeName);
    result := found;
  end;
end;

procedure PurgeFile(const Path, Name: string);
begin
  If KillFiles then
  begin
    if FileDelete(Path+Name) then
      LogWriteLn('deleted old file "' + Path+Name + '"')
    else
      LogWriteLn('! unable to delete old file "' + Path+Name + '"');
  end else
  begin
    if FileRenameEx(Path+Name, AddBkSlash(ArchivePath)+Name) then
      LogWriteLn('moved old file "' + Path+Name + '" to "' + ArchivePath + '"')
    else
      LogWriteLn('! unable to move old file "' + Path+Name + '" to "' + ArchivePath + '"');
  end;
end;

procedure PurgeDir(const Path: string; MaxAge: integer);
var
  SR: SearchRec;
begin
  FindFirst(Path + '*', AnyFile-Directory-VolumeID, SR);
  if (DosError <> 0) and (DosError <> 18) then
    Info('Warning: directory "' + Path + '" doen not exist or acces is denied');
  while DosError = 0 do
  begin
    if (Age(SR.Time) >= MaxAge) and not InExcludeList(UpStr(SR.Name)) then
      PurgeFile(Path, SR.Name);
    FindNext(SR);
  end;
  FindClose(SR);
end;

procedure Purge;

  procedure DoPurge(ps: pstring);
  var
    PurgePath   : string;
    PurgeMaxAge : integer;
  begin
    if not SplitPathAge(pstring(ps)^, PurgePath, PurgeMaxAge) then
    begin
      Info('Warning: age value of "' + PurgePath + '" is incorrect, using default value');
      PurgeMaxAge := DefAge;
    end;

    if PurgeMaxAge > 0 then
      PurgeDir(PurgePath, PurgeMaxAge);
  end;

begin
  // если пуржить нечего, выходим.
  if PurgeDirs^.Count = 0 then
  begin
    Info('Warning: nothing to purge');
    exit;
  end;

  // если установлен режим перемещения в архив, проверим директорию.
  if not KillFiles then
  begin
    if Length(ArchivePath) = 0 then
    begin
      Info('Error: ArchivePath is not defined');
      exit;
    end;
    if not (DirExists(AddBkSlash(ArchivePath)) or DirCreate(RemoveBkSlash(ArchivePath))) then
    begin
      Info('Error: unable to create directory "' + ArchivePath + '"');
      exit;
    end;
  end;

  InitExcludeNames;

  Info('Purging');
  PurgeDirs^.ForEach(@DoPurge);
  Info('Done');

  FreeExcludeNames;
end;

end.
