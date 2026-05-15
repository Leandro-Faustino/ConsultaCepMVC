unit ConsultaCEP.Tests.Service;

interface

uses
  ConsultaCEP.DTO,
  ConsultaCEP.Interfaces,
  ConsultaCEP.Service,
  DUnitX.TestFramework,
  System.SysUtils;

type
  TFakeGateway = class(TInterfacedObject, IGatewayEndereco)
  public
    Chamadas: Integer;
    DTO: TDadosEnderecoDTO;
    DeveFalhar: Boolean;
    function Nome: string;
    function BuscarEndereco(const ACEP: string): TDadosEnderecoDTO;
  end;

  TFakeRepositorio = class(TInterfacedObject, IRepositorioConsulta)
  public
    ChamadasSalvar: Integer;
    DeveFalharAoSalvar: Boolean;
    Registros: TArray<TConsultaCEPRecord>;
    function Salvar(const AConsulta: TConsultaCEPRecord): Int64;
    function ListarRecentes(AMaxRegistros: Integer): TArray<TConsultaCEPRecord>;
  end;

  TFakeLogger = class(TInterfacedObject, ILogger)
  public
    Erros: Integer;
    procedure Info(const AMsg: string);
    procedure Erro(const AMsg: string);
  end;

  [TestFixture]
  TConsultaCEPServiceTests = class
  private
    FGatewayObj: TFakeGateway;
    FRepoObj: TFakeRepositorio;
    FGateway: IGatewayEndereco;
    FRepo: IRepositorioConsulta;
    FLogger: ILogger;
    FService: IConsultaCEPService;
    procedure CriarService;
  public
    [Setup]
    procedure Setup;

    [Test]
    procedure CEPInvalidoNaoChamaGatewayNemRepositorio;

    [Test]
    procedure CEPSucessoChamaGatewayESalvaHistorico;

    [Test]
    procedure ErroDeAPIEConvertidoEmDTOEPersistido;

    [Test]
    procedure FalhaAoSalvarNaoImpedeRetornoDoDTO;
  end;

implementation

function TFakeGateway.BuscarEndereco(const ACEP: string): TDadosEnderecoDTO;
begin
  Inc(Chamadas);
  if DeveFalhar then
    raise Exception.Create('timeout fake');

  Result := DTO;
  Result.CEP := ACEP;
end;

function TFakeGateway.Nome: string;
begin
  Result := 'FakeGateway';
end;

procedure TFakeLogger.Erro(const AMsg: string);
begin
  Inc(Erros);
end;

procedure TFakeLogger.Info(const AMsg: string);
begin
end;

function TFakeRepositorio.ListarRecentes(
  AMaxRegistros: Integer): TArray<TConsultaCEPRecord>;
begin
  Result := Registros;
end;

function TFakeRepositorio.Salvar(
  const AConsulta: TConsultaCEPRecord): Int64;
begin
  Inc(ChamadasSalvar);
  if DeveFalharAoSalvar then
    raise Exception.Create('falha fake de banco');

  SetLength(Registros, Length(Registros) + 1);
  Registros[High(Registros)] := AConsulta;
  Result := Length(Registros);
end;

procedure TConsultaCEPServiceTests.CEPInvalidoNaoChamaGatewayNemRepositorio;
var
  LDTO: TDadosEnderecoDTO;
begin
  LDTO := FService.ConsultarCEP('123');

  Assert.AreEqual(rcCEPInvalido, LDTO.Resultado);
  Assert.AreEqual(0, FGatewayObj.Chamadas);
  Assert.AreEqual(0, FRepoObj.ChamadasSalvar);
end;

procedure TConsultaCEPServiceTests.CEPSucessoChamaGatewayESalvaHistorico;
var
  LDTO: TDadosEnderecoDTO;
begin
  FGatewayObj.DTO.Resultado := rcSucesso;
  FGatewayObj.DTO.Logradouro := 'Rua Teste';
  FGatewayObj.DTO.Cidade := 'Joinville';
  FGatewayObj.DTO.UF := 'SC';

  LDTO := FService.ConsultarCEP('89201000');

  Assert.AreEqual(rcSucesso, LDTO.Resultado);
  Assert.AreEqual(1, FGatewayObj.Chamadas);
  Assert.AreEqual(1, FRepoObj.ChamadasSalvar);
  Assert.AreEqual('FakeGateway', FRepoObj.Registros[0].GatewayUsado);
end;

procedure TConsultaCEPServiceTests.CriarService;
begin
  FGatewayObj := TFakeGateway.Create;
  FRepoObj := TFakeRepositorio.Create;
  FGateway := FGatewayObj;
  FRepo := FRepoObj;
  FLogger := TFakeLogger.Create;
  FService := TConsultaCEPService.Create(FGateway, FRepo, FLogger);
end;

procedure TConsultaCEPServiceTests.ErroDeAPIEConvertidoEmDTOEPersistido;
var
  LDTO: TDadosEnderecoDTO;
begin
  FGatewayObj.DeveFalhar := True;

  LDTO := FService.ConsultarCEP('89201000');

  Assert.AreEqual(rcErroAPI, LDTO.Resultado);
  Assert.AreEqual(1, FGatewayObj.Chamadas);
  Assert.AreEqual(1, FRepoObj.ChamadasSalvar);
end;

procedure TConsultaCEPServiceTests.FalhaAoSalvarNaoImpedeRetornoDoDTO;
var
  LDTO: TDadosEnderecoDTO;
begin
  FGatewayObj.DTO.Resultado := rcSucesso;
  FGatewayObj.DTO.Cidade := 'Joinville';
  FRepoObj.DeveFalharAoSalvar := True;

  LDTO := FService.ConsultarCEP('89201000');

  Assert.AreEqual(rcSucesso, LDTO.Resultado);
  Assert.AreEqual(1, FRepoObj.ChamadasSalvar);
end;

procedure TConsultaCEPServiceTests.Setup;
begin
  CriarService;
end;

initialization
  TDUnitX.RegisterTestFixture(TConsultaCEPServiceTests);

end.
