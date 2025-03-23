program FPurge;

{$MODE objfpc}

uses
  fp_CmdLine,
  fp_Cfg,
  fp_Log,
  fp_Purge,
  fp_Scan,
  fp_Vars;

begin
  fp_CmdLine.ParseCmdLine;
  fp_Cfg.ParseCfg;
  fp_Log.LogOpen;
  if fp_Purge.InitPurgeDirs then
  begin
    if ScanMode then
      fp_Scan.ScanRootDirs;
    if PurgeMode then
      fp_Purge.Purge;
    fp_Purge.FreePurgeDirs;
  end;
  fp_Log.LogClose;
end.
