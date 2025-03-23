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

    // ищем первый разделяющий символ, если не находим, выходим.
    i := pos(delim, pstring(ps)^);
    if i = 0 then exit;

    // копируем часть строки с начала до первого встреченного разделителя
    tmp := copy(pstring(ps)^, 1, i-1);

    // сравниваем значение с названием искомого параметра, выходим, если не совпадают
    if UpStr(tmp) <> key then exit;

    // копируем часть строки после первого встреченного разделителя до конца, удаляем лишние пробелы слева.
    tmp := LTrim(copy(pstring(ps)^, i+1, length(pstring(ps)^)-i));

    // если строка пустая, выходим.
    if length(tmp) = 0 then exit;

    // присваиваем значение переменной, ставим флаг.
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
