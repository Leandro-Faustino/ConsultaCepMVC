program ConsultaCEP.Tests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.TestFramework,
  DUnitX.TestRunner,
  ConsultaCEP.Tests.CEP in 'ConsultaCEP.Tests.CEP.pas',
  ConsultaCEP.Tests.Service in 'ConsultaCEP.Tests.Service.pas',
  ConsultaCEP.CEP in '..\Source\Domain\ConsultaCEP.CEP.pas',
  ConsultaCEP.DTO in '..\Source\Domain\ConsultaCEP.DTO.pas',
  ConsultaCEP.Interfaces in '..\Source\Domain\ConsultaCEP.Interfaces.pas',
  ConsultaCEP.Service in '..\Source\Service\ConsultaCEP.Service.pas';

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
