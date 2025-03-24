unit DateDiff;

{$MODE objfpc}

interface

function Age(D: longint): longint;
function AgeDT(D: TDateTime): longint;

implementation

uses
  SysUtils,
  DateUtils;

function Age(D: longint): longint;
begin
  result := DaysBetween(Now, DosDateTimeToDateTime(D));
end;

function AgeDT(D: TDateTime): longint;
begin
  result := DaysBetween(Now, D);
end;

end.
