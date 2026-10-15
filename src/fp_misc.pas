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
  Classes,
  fp_Vars;

function AddBkSlash(Path: string): string;
function RemoveBkSlash(Path: string): string;
{$IFDEF Windows}
function GetFileCreationTime(const FileName: AnsiString; out CreationTime: TDateTime): Boolean;
{$ENDIF}
function GetFileAge(const FileName: AnsiString; out DT: TDateTime): Boolean;
function FileCopy(const OldName, NewName: string): Boolean;
function FileRename(const OldName, NewName: string): boolean;
function FileRenameEx(const OldName, NewName: string): boolean;
function CheckWildcard(const Src, Mask: String): Boolean;
function IsWildcard(const Mask: String): Boolean;
procedure Info(const s: string);
function SplitPathAge(const PathAge: string; var Path: string; var Age: integer): boolean;

implementation

procedure Info(const s: string);
begin
  if not Quiet then WriteLn(s);
end;

function AddBkSlash(Path: string): string;
begin
  if Path[Length(Path)] = DirectorySeparator then
    Result := Path
  else
    Result := Path + DirectorySeparator;
end;

function RemoveBkSlash(Path: string): string;
begin
  if Path[Length(Path)] = DirectorySeparator then
    Result := Copy(Path, 1, Length(Path)-1)
  else
    Result := Path;
end;

{$IFDEF Windows}
function GetFileCreationTime(const FileName: AnsiString; out CreationTime: TDateTime): Boolean;
var
  Handle: THandle;
  FileCreationTime, LastAccessTime, LastWriteTime: TFileTime;
  SysTime: TSystemTime;
begin
  Result := False;

  Handle := CreateFile(PAnsiChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
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

function FileCopy(const OldName, NewName: string): Boolean;
var
  Src, Dst: TFileStream;
begin
  if OldName = NewName then
    Exit(False);

  try
    Src := TFileStream.Create(OldName, fmOpenRead or fmShareDenyNone);
    try
      Dst := TFileStream.Create(NewName, fmCreate);
      try
        Dst.CopyFrom(Src, 0);
        Result := True;
      finally
        Dst.Free;
      end;
    finally
      Src.Free;
    end;
  except
    Result := False;
  end;
end;

function FileRename(const OldName, NewName: string): Boolean;
begin
  if OldName = NewName then
    Exit(False);

  Result := RenameFile(OldName, NewName);
  if Result then
    Exit;

  Result := FileCopy(OldName, NewName);
  if Result then
    Result := DeleteFile(OldName)
  else
    Result := DeleteFile(NewName);
end;

function FileRenameEx(const OldName, NewName: string): boolean;
var
  DT: TDateTime;
begin
  if not GetFileAge(OldName, DT) then
  begin
    Result := false;
    Exit;
  end;

  Result := FileRename(OldName, ChangeFileExt(NewName, '-' +
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
    Result := false;
    Path := AddBkSlash(PathAge);
  end else
  begin
    Path := AddBkSlash(Copy(PathAge, 1, i-1));
    s := Copy(PathAge, i+1, Length(PathAge)-i);
    Val(s, Age, i);
    if i = 0 then
      Result := true
    else
      Result := false;
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
