unit fp_Misc;
{ most stuff is taken from wizard.pas (q) sk }

{$I-}
{$MODE objfpc}

interface

uses
  {$IFDEF Windows}
  Windows,
  {$ENDIF}
  SysUtils,
  Dos,
  fp_Vars;

// strings stuff
function UpStr(const s: string): string;
function LTrim(S: String): String;
function RTrim(S: String): String;
function Trim(S: String): String;
procedure TrimEx(var S: String);

// file stuff
function AddBkSlash(Path: string): string;
function RemoveBkSlash(Path: string): string;
{$IFDEF Windows}
function GetFileCreationTime(const FileName: AnsiString; out CreationTime: TDateTime): Boolean;
{$ENDIF}
function GetFileAge(const FileName: AnsiString; out DT: TDateTime): Boolean;
function DirExists(Path: string): boolean;
function DirCreate(Path: string): boolean;
function FileExists(const Name: string): boolean;
function FileDelete(const Name: string): boolean;
function FileRename(const OldName, NewName: string): boolean;
function FileRenameEx(const OldName, NewName: string): boolean;
function CheckWildcard(const Src, Mask: String): Boolean;
function IsWildcard(const Mask: String): Boolean;

// misc stuff
procedure Info(const s: string);
function SplitPathAge(const PathAge: string; var Path: string; var Age: integer): boolean;

implementation

function LTrim(S: String): String;
var
  K: Byte;
begin
  K:=1;

  while (K <= Length(S)) and (S[K] = ' ') do
    Inc(K);

  LTrim:=Copy(S, K, 255);
end;

function RTrim(S: String): String;
var
  L: Byte;
begin
  L:=Length(S);

  while (L <> 0) and (S[L] = ' ') do
    Dec(L);

  RTrim:=Copy(S, 1, L);
end;

procedure TrimEx(var S: String);
var
  K, L: Byte;
begin
  K:=1;

  while (K <= Length(S)) and (S[K] = ' ') do
    Inc(K);

  L:=Length(S);

  while (L <> 0) and (S[L] = ' ') do
    Dec(L);

  Dec(L, K);
  Inc(L);

  S:=Copy(S, K, L);
end;

function Trim(S: String): String;
begin
  TrimEx(S);

  Trim:=S;
end;

function UpStr(const s: string): string;
var
  i: byte;
begin
  for i := 1 to Length(s) do result[i] := UpCase(s[i]);
  result[0] := s[0];
end;

procedure Info(const s: string);
begin
  if not Quiet then WriteLn(s);
end;

function AddBkSlash(Path: string): string;
begin
  if Path[Length(Path)] = DirectorySeparator then
    result := Path
  else
    result := Path + DirectorySeparator;
end;

function RemoveBkSlash(Path: string): string;
begin
  if Path[Length(Path)] = DirectorySeparator then
    result := copy(Path, 1, Length(Path)-1)
  else
    result := Path;
end;

{$IFDEF Windows}
function GetFileCreationTime(const FileName: AnsiString; out CreationTime: TDateTime): Boolean;
var
  Handle: THandle;
  FileCreationTime, LastAccessTime, LastWriteTime: TFileTime;
  SysTime: TSystemTime;
begin
  Result := False;

  Handle := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if Handle = INVALID_HANDLE_VALUE then
    Exit;

  if GetFileTime(Handle, @FileCreationTime, @LastAccessTime, @LastWriteTime) then
  begin
    FileTimeToSystemTime(FileCreationTime, SysTime);
    CreationTime := SystemTimeToDateTime(SysTime);
    Result := True;
  end;

  CloseHandle(Handle);
end;
{$ENDIF}

function GetFileAge(const FileName: AnsiString; out DT: TDateTime): Boolean;
begin
  {$IFDEF Windows}
  Result := (UseCreationTime and GetFileCreationTime(FileName, DT));
  if not Result then
  {$ENDIF}
    Result := FileAge(FileName, DT);
end;

function DirExists(Path: string): boolean;
var
  SR: SearchRec;
begin
  FindFirst(Path + '*', AnyFile, SR);
  result := DosError = 0;
  FindClose(SR);
end;

function DirCreate(Path: string): boolean;
begin
  MkDir(Path);
  result := IOResult = 0;
end;

function FileExists(const Name: string): boolean;
var
  f: file;
  a: word;
begin
  assign(f, name);
  GetFAttr(f, a);
  result := DosError = 0;
end;

function FileDelete(const Name: string): boolean;
var
  f: file;
begin
  assign(f, Name);
  erase(f);
  result := IOResult = 0;
end;

function FileRename(const OldName, NewName: string): boolean;
var
  f: file;
begin
  assign(f, OldName);
  rename(f, NewName);
  result := IOResult = 0;
end;

function FileRenameEx(const OldName, NewName: string): boolean;
var
  DT: TDateTime;
begin
  if not GetFileAge(OldName, DT) then
  begin
    result := false;
    exit;
  end;

  result := FileRename(OldName, ChangeFileExt(NewName, '-' +
    FormatDateTime('yyyymmdd-hhnnss', DT) + ExtractFileExt(NewName)));
end;

// true if age is extracted, false if not.
function SplitPathAge(const PathAge: string; var Path: string; var Age: integer): boolean;
var
  i: longint;
  s: string;
begin
  i := Pos('|', PathAge);
  if i = 0 then
  begin
    result := false;
    Path := AddBkSlash(PathAge);
  end else
  begin
    Path := AddBkSlash(Copy(PathAge, 1, i-1));
    s := Copy(PathAge, i+1, Length(PathAge)-i);
    Val(s, Age, i);
    if i = 0 then
      result := true
    else
      result := false;
  end;
end;

{
  CheckWildcard (WildEqu)
  (c) by Vladimir S. Lokhov <vsl@tula.net> <2:5022/18.14>, 1994-2000.
}

type
  TCheckWildcardStack = packed record
    Src, Mask: Byte;
  end;

function CheckWildcard(const Src, Mask: String): Boolean;
var
  Stack: array[1..128] of TCheckWildcardStack;
  StackPointer,
  SrcPosition, MaskPosition,
  SrcLength, MaskLength: Byte;
begin
  CheckWildcard:=False;

  if (Mask = '') and (Src <> '') then
    Exit;

  MaskLength:=Length(Mask);
  SrcLength:=Length(Src);

  if Mask[MaskLength] <> '*' then
    while (MaskLength > 1) and (SrcLength > 1) do
    begin
      if (Mask[MaskLength] = '*') or (Mask[MaskLength] = '?') then
        Break;

      if Mask[MaskLength] <> Src[SrcLength] then
        Exit;

      Dec(MaskLength);
      Dec(SrcLength);
    end;

  if Mask[MaskLength] = '*' then
    while (Mask[MaskLength - 1] = '*') and (MaskLength > 1) do
      Dec(MaskLength);

  StackPointer:=0;

  SrcPosition:=1;
  MaskPosition:=1;

  while (SrcPosition <= SrcLength) and (MaskPosition <= MaskLength) do
  begin
    case Mask[MaskPosition] of
      '?':
      begin
        Inc(SrcPosition);
        Inc(MaskPosition);
      end;
      '*':
      begin
        if (MaskPosition = 1) or (Mask[MaskPosition - 1] <> '*') then
        Inc(StackPointer);

        Stack[StackPointer].Mask:=MaskPosition;

        Inc(MaskPosition);

        if MaskPosition <= MaskLength then
          if (Mask[MaskPosition] <> '?') and (Mask[MaskPosition] <> '*') then
            while (SrcPosition <= Length(Src)) and (Src[SrcPosition] <> Mask[MaskPosition]) do
              Inc(SrcPosition);

        Stack[StackPointer].Src:=SrcPosition + 1;
      end;
    else
      if Src[SrcPosition] = Mask[MaskPosition] then
      begin
        Inc(SrcPosition);
        Inc(MaskPosition);
      end else
      begin
        if StackPointer = 0 then
          Exit;

        SrcPosition:=Stack[StackPointer].Src;
        MaskPosition:=Stack[StackPointer].Mask;

        Dec(StackPointer)
      end;
    end;

    while not ((SrcPosition <= SrcLength) xor (MaskPosition > MaskLength)) do
    begin
      if (MaskPosition >= MaskLength) and (Mask[MaskLength] = '*') then
        Break;

      if StackPointer = 0 then
        Exit;

      SrcPosition:=Stack[StackPointer].Src;
      MaskPosition:=Stack[StackPointer].Mask;

      Dec(StackPointer)
    end;
  end;

  CheckWildcard:=True;
end;

function IsWildcard(const Mask: String): Boolean;
begin
  IsWildcard:=(Pos('*', Mask) > 0) or (Pos('?', Mask) > 0);
end;

end.
