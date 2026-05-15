program ConsultaCEP.Tests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.TestFramework,
  DUnitX.TestRunner,
  ConsultaCEP.Tests.Model in 'ConsultaCEP.Tests.Model.pas',
  ConsultaCEP.DTO in '..\Source\Domain\ConsultaCEP.DTO.pas',
  ConsultaCEP.Interfaces in '..\Source\Domain\ConsultaCEP.Interfaces.pas',
  ConsultaCEP.Model in '..\Source\Model\ConsultaCEP.Model.pas';

var
  LRunner: ITestRunner;
  LResults: IRunResults;
begin
  TDUnitX.CheckCommandLine;
  LRunner := TDUnitX.CreateRunner;
  LRunner.UseRTTI := True;
  LRunner.AddLogger(TDUnitXConsoleLogger.Create(True));
  LResults := LRunner.Execute;
  if not LResults.AllPassed then
    System.ExitCode := 1;

  if DebugHook <> 0 then
  begin
    Writeln;
    Writeln('Pressione ENTER para fechar...');
    Readln;
  end;
end.
