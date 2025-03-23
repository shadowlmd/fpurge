unit CfgParser;

{$I-}
{$MODE objfpc}

interface

uses
  Objects,
  fp_Misc;

const
  vtStr  = 1;
  vtInt  = 2;
  vtBool = 3;

var
  CfgLastError: string;

function CfgLoad(const cfg: PStringCollection; const filename: string; comment: char; ucase: boolean): boolean;
function CfgGetKeyValue(const cfg: PStringCollection; const key: string; delim: char; vt: byte; var value): boolean;

implementation

function CfgLoad(const cfg: PStringCollection; const filename: string; comment: char; ucase: boolean): boolean;
var
  f: text;
  s: string;
  i: longint;
begin
  assign(f, filename);
  reset(f);
  if ioresult <> 0 then
  begin
    result := false;
    CfgLastError := 'unable to open ' + filename + ' for reading';
    exit;
  end;

  while not eof(f) do
  begin
    readln(f, s);
    if length(s) = 0 then
      continue;
    TrimEx(s);
    if s[1] = comment then
      continue;
    i := pos(comment, s);
    if i > 0 then
      s := RTrim(copy(s, 1, i-1));
    if ucase then
      s := UpStr(s);
    cfg^.Insert(NewStr(s));
  end;

  close(f);
  result := true;
end;

function CfgGetKeyValue(const cfg: PStringCollection; const key: string; delim: char; vt: byte; var value): boolean;
var
  found    : boolean;
  i        : longint;
  StrValue : string;

  function ExtractValue(ps: pstring): boolean;
  var
    tmp  : string;
    i    : byte;
  begin
    result := false;

    // �饬 ���� ࠧ�����騩 ᨬ���, �᫨ �� ��室��, ��室��.
    i := pos(delim, pstring(ps)^);
    if i = 0 then exit;

    // �����㥬 ���� ��ப� � ��砫� �� ��ࢮ�� ����祭���� ࠧ����⥫�
    tmp := copy(pstring(ps)^, 1, i-1);

    // �ࠢ������ ���祭�� � ��������� �᪮���� ��ࠬ���, ��室��, �᫨ �� ᮢ������
    if UpStr(tmp) <> key then exit;

    // �����㥬 ���� ��ப� ��᫥ ��ࢮ�� ����祭���� ࠧ����⥫� �� ����, 㤠�塞 ��譨� �஡��� ᫥��.
    tmp := LTrim(copy(pstring(ps)^, i+1, length(pstring(ps)^)-i));

    // �᫨ ��ப� �����, ��室��.
    if length(tmp) = 0 then exit;

    // ��ᢠ����� ���祭�� ��६�����, �⠢�� 䫠�.
    StrValue := tmp;
    found := true;
    result := true;
  end;

begin
  found := false;
  cfg^.FirstThat(@ExtractValue);
  if not found then
  begin
    result := false;
    CfgLastError := 'key "' + key + '" does not exist';
    exit;
  end;

  result := true;

  case vt of
    vtStr:
      string(value) := StrValue;

    vtInt:
    begin
      val(StrValue, integer(value), i);
      if i <> 0 then
      begin
        result := false;
        CfgLastError := 'value of "' + key + '" must be a valid number';
      end;
    end;

    vtBool:
    begin
      if UpStr(StrValue) = 'YES' then boolean(value) := true  else
      if UpStr(StrValue) = 'NO'  then boolean(value) := false else
      begin
        result := false;
        CfgLastError := 'value of "' + key + '" must be "Yes" or "No"';
      end;
    end;
  end;
end;

end.
