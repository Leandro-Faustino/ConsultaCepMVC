unit App.Registration;

interface

uses
  ConsultaCEP.View.Main;

type
  TAppRegistration = class
  public
    class procedure Configurar(AForm: TFormMain); static;
  end;

implementation

uses
  ConsultaCEP.Controller,
  ConsultaCEP.Gateway.BrasilAPI,
  ConsultaCEP.Gateway.ViaCEP,
  ConsultaCEP.Interfaces,
  ConsultaCEP.Model,
  ConsultaCEP.Repository.FireDAC,
  FireDAC.Comp.Client,
  System.SysUtils,
  Vcl.Dialogs;

var
  GConnection: TFDConnection;
  GController: IConsultaCEPController;

function ResolverCaminhoBanco: string;
var
  LExeDir: string;
  LProjectDirFromDebug: string;
begin
  LExeDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  Result := LExeDir + 'Database\CONSULTACEP_MVC.FDB';
  if FileExists(Result) then
    Exit;

  LProjectDirFromDebug := ExpandFileName(LExeDir + '..\..\Database\CONSULTACEP_MVC.FDB');
  if FileExists(LProjectDirFromDebug) then
    Exit(LProjectDirFromDebug);
end;

class procedure TAppRegistration.Configurar(AForm: TFormMain);
var
  LGateway: IGatewayEndereco;
  LRepositorio: IRepositorioConsulta;
  LModel: IConsultaCEPModel;
  LDatabase: string;
begin
  if AForm = nil then
    raise EArgumentNilException.Create('AForm nao pode ser nil');

  LDatabase := ResolverCaminhoBanco;

  GConnection := TFDConnection.Create(nil);
  GConnection.DriverName := 'FB';
  GConnection.LoginPrompt := False;
  GConnection.Params.Values['Database'] := LDatabase;
  GConnection.Params.Values['User_Name'] := 'SYSDBA';
  GConnection.Params.Values['Password'] := 'masterkey';
  GConnection.Params.Values['CharacterSet'] := 'UTF8';
  GConnection.Params.Values['Protocol'] := 'TCPIP';
  GConnection.Params.Values['Server'] := 'localhost';

  LGateway := TViaCEPAdapter.Create;
  // Para trocar sem tocar nas camadas: use TBrasilAPIAdapter.Create aqui.
  // LGateway := TBrasilAPIAdapter.Create;

  LRepositorio := TRepositorioConsultaFireDAC.Create(GConnection);
  LModel := TConsultaCEPModel.Create(LGateway, LRepositorio);
  GController := TConsultaCEPController.Create(AForm, LModel);
  AForm.SetController(GController);

  try
    AForm.ExibirMensagem('Pronto. Crie o banco com SQL\ConsultaCEP.Firebird.ddl.sql antes de consultar.');
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

initialization

finalization
  GController := nil;
  GConnection.Free;

end.
