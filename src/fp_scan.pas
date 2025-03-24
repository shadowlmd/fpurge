unit fp_Scan;

{$I-}
{$MODE objfpc}

interface

uses
  Objects,
  Dos,
  CfgParser,
  fp_Misc,
  fp_Log,
  fp_Vars;

procedure ScanRootDirs;

implementation

function InitRootDirs: boolean;
begin
  if Length(RootDirsList) = 0 then
  begin
    Info('Warning: RootDirsList is not defined');
    result := false;
    exit;
  end;

  RootDirs := New(PStringCollection, Init(10, 10));
  RootDirs^.Duplicates := true;

  Info('Reading ' + RootDirsList);
  if not CfgLoad(RootDirs, RootDirsList, ';', false) then
  begin
    Info('Error: ' + CfgLastError);
    result := false;
    exit;
  end;
  Info('Done');
  result := true;
end;

procedure FreeRootDirs;
begin
  Dispose(RootDirs, Done);
end;

procedure CleanPurgeDirs;
var
  s   : string;
  i   : longint;
  tmp : integer;
begin
  for i := PurgeDirs^.Count-1 downto 0 do
  begin
    SplitPathAge(pstring(PurgeDirs^.At(i))^, s, tmp);
    if not DirExists(s) then
    begin
      LogWriteLn('non-existent directory "' + s + '" removed from list');
      PurgeDirs^.AtFree(i);
    end;
  end;
end;

procedure SavePurgeList;
var
  f: text;

  procedure DoSavePurgeList(ps: pstring);
  begin
    WriteLn(f, pstring(ps)^);
  end;

begin // SavePurgeList
  assign(f, PurgeList);
  rewrite(f);
  if IOResult <> 0 then
  begin
    Info('Error: unable to open "' + PurgeList + '" for writing');
    exit;
  end;

  Info('Saving ' + PurgeList);

  // комменты
  WriteLn(f, '; Файл описания обрабатываемых директорий.');
  WriteLn(f, ';');
  WriteLn(f, '; Формат:');
  WriteLn(f, ';');
  WriteLn(f, '; Каждая строка файла - описание директории.');
  WriteLn(f, '; В имени директории после знака | указывается');
  WriteLn(f, '; максимальный возраст файлов в ней.');
  WriteLn(f, ';');
  WriteLn(f, '; Пример описания:');
  WriteLn(f, ';');
  WriteLn(f, ';c:\fileecho\aftnmisc\|90');
  WriteLn(f);

  PurgeDirs^.ForEach(@DoSavePurgeList);
  Info('Done');

  close(f);
end;

function InPurgeList(const Path: string): boolean;
var
  found: boolean;

  function MatchPurgeDir(ps: pstring): boolean;
  var
    s: string;
    i: integer;
  begin
    SplitPathAge(pstring(ps)^, s, i);
    if Path = UpStr(s) then
    begin
      found := true;
      result := true;
    end else
      result := false;
  end;

begin // InPurgeList
  if PurgeDirs^.Count = 0 then
    result := false
  else
  begin
    found := false;
    PurgeDirs^.FirstThat(@MatchPurgeDir);
    result := found;
  end;
end;

procedure ScanRootDirs;

  procedure DoScan(ps: pstring);
  var
    DefAgeStr,
    Path        : string;
    SR          : SearchRec;
  begin
    Path := AddBkSlash(pstring(ps)^);

    FindFirst(Path + '*', Directory, SR);
    if (DosError <> 0) and (DosError <> 18) then
      Info('Warning: directory "' + Path + '" doen not exist or acces is denied');
    while DosError = 0 do
    begin
      if not ((SR.Name = '.') or (SR.Name = '..') or InPurgeList(UpStr(Path+SR.Name)+DirectorySeparator)) then
      begin
        LogWriteLn('found new directory: "' + Path+SR.Name + '"');
        Str(DefAge, DefAgeStr);
        PurgeDirs^.Insert(NewStr(Path+SR.Name + DirectorySeparator + '|' + DefAgeStr));
      end;

      FindNext(SR);
    end;
    FindClose(SR);
  end;

begin // ScanRootDirs

  if InitRootDirs then
  begin
    if RootDirs^.Count > 0 then
    begin
      Info('Scanning');
      RootDirs^.ForEach(@DoScan);
      Info('Done');
    end else
      Info('Warinig: nothing to scan');
    FreeRootDirs;
  end;

  if PurgeDirs^.Count = 0 then exit;

  CleanPurgeDirs;
  SavePurgeList;
end;

end.
