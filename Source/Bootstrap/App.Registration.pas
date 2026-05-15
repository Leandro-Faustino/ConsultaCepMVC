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
  ConsultaCEP.Logger,
  ConsultaCEP.Repository.FireDAC,
  ConsultaCEP.Service,
  FireDAC.Comp.Client,
  FireDAC.Comp.UI,
  FireDAC.Stan.Def,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Pool,
  System.IniFiles,
  System.SysUtils;

const
  CConnectionDefName = 'ConsultaCEP_Pool';

var
  GController: IConsultaCEPController;

function AppPath(const ARelativePath: string): string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    ARelativePath;
end;

function ProjectPathFallback(const ARelativePath: string): string;
begin
  Result := ExpandFileName(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    '..\..\' + ARelativePath);
end;

function ResolverCaminhoBanco(const AConfiguredPath: string): string;
begin
  if not AConfiguredPath.Trim.IsEmpty then
    Exit(ExpandFileName(AConfiguredPath));

  Result := AppPath('Database\CONSULTACEP_MVC.FDB');
  if FileExists(Result) then
    Exit;

  Result := ProjectPathFallback('Database\CONSULTACEP_MVC.FDB');
end;

function ResolverCaminhoIni: string;
begin
  Result := AppPath('config\ConsultaCEP.ini');
  if FileExists(Result) then
    Exit;

  Result := ProjectPathFallback('config\ConsultaCEP.ini');
end;

procedure RegistrarConnectionDef(const ADatabase: string);
var
  LDef: IFDStanConnectionDef;
begin
  if FDManager.ConnectionDefs.FindConnectionDef(CConnectionDefName) <> nil then
    Exit;

  LDef := FDManager.ConnectionDefs.AddConnectionDef;
  LDef.Name := CConnectionDefName;
  LDef.Params.DriverID := 'FB';
  LDef.Params.Values['Database'] := ADatabase;
  LDef.Params.Values['User_Name'] := 'SYSDBA';
  LDef.Params.Values['Password'] := 'masterkey';
  LDef.Params.Values['CharacterSet'] := 'UTF8';
  LDef.Params.Values['Protocol'] := 'TCPIP';
  LDef.Params.Values['Server'] := 'localhost';
  LDef.Params.Values['Pooled'] := 'True';
  LDef.Params.Values['POOL_MaximumItems'] := '5';
  FDManager.Active := True;
end;

function CriarConnectionFactory: TConnectionFactory;
begin
  Result :=
    function: TFDConnection
    begin
      Result := TFDConnection.Create(nil);
      Result.LoginPrompt := False;
      Result.ConnectionDefName := CConnectionDefName;
      Result.Connected := True;
    end;
end;

function CriarGateway(const AIni: TIniFile): IGatewayEndereco;
var
  LGateway: string;
begin
  LGateway := AIni.ReadString('Gateway', 'Ativo', 'ViaCEP').Trim;
  if SameText(LGateway, 'BrasilAPI') then
    Exit(TBrasilAPIAdapter.Create(AIni.ReadString('BrasilAPI', 'URLBase',
      'https://brasilapi.com.br/api/cep/v1')));

  Result := TViaCEPAdapter.Create(AIni.ReadString('ViaCEP', 'URLBase',
    'https://viacep.com.br/ws'));
end;

class procedure TAppRegistration.Configurar(AForm: TFormMain);
var
  LIni: TIniFile;
  LGateway: IGatewayEndereco;
  LRepositorio: IRepositorioConsulta;
  LService: IConsultaCEPService;
  LLogger: ILogger;
  LConnectionFactory: TConnectionFactory;
  LDatabase: string;
begin
  if AForm = nil then
    raise EArgumentNilException.Create('AForm nao pode ser nil');

  LIni := TIniFile.Create(ResolverCaminhoIni);
  try
    LDatabase := ResolverCaminhoBanco(LIni.ReadString('Database', 'Path', ''));
    RegistrarConnectionDef(LDatabase);

    LConnectionFactory := CriarConnectionFactory();
    LGateway := CriarGateway(LIni);
    LLogger := TFileLogger.Create(AppPath('logs\ConsultaCEP.log'));
    LRepositorio := TRepositorioConsultaFireDAC.Create(LConnectionFactory);
    LService := TConsultaCEPService.Create(LGateway, LRepositorio, LLogger);
    GController := TConsultaCEPController.Create(AForm, LService, LLogger);
    AForm.SetController(GController);
    AForm.ExibirMensagem('Pronto.');
  finally
    LIni.Free;
  end;
end;

initialization

finalization
  GController := nil;

end.
