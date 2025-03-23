unit DateDiff;

{$MODE objfpc}

interface

function Age(D: longint): longint;

implementation

uses
  SysUtils,
  DateUtils;

function Age(D: longint): longint;
begin
  result := DaysBetween(Now, DosDateTimeToDateTime(D));
end;

end.
