unit ConsultaCEP.Tests.Model;

interface

uses
  ConsultaCEP.DTO,
  ConsultaCEP.Interfaces,
  ConsultaCEP.Model,
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
    function ListarTodos: TArray<TConsultaCEPRecord>;
  end;

  [TestFixture]
  TConsultaCEPModelTests = class
  private
    FGatewayObj: TFakeGateway;
    FRepoObj: TFakeRepositorio;
    FGateway: IGatewayEndereco;
    FRepo: IRepositorioConsulta;
    FModel: IConsultaCEPModel;
    procedure CriarModel;
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
    Exit(TDadosEnderecoDTO.ErroAPI(ACEP, 'timeout fake'));

  Result := DTO;
  Result.CEP := ACEP;
end;

function TFakeGateway.Nome: string;
begin
  Result := 'FakeGateway';
end;

function TFakeRepositorio.ListarTodos: TArray<TConsultaCEPRecord>;
begin
  Result := Registros;
end;

function TFakeRepositorio.Salvar(
  const AConsulta: TConsultaCEPRecord): Int64;
begin
  Inc(ChamadasSalvar);
  if DeveFalharAoSalvar then
    Exit(-1);

  SetLength(Registros, Length(Registros) + 1);
  Registros[High(Registros)] := AConsulta;
  Result := Length(Registros);
end;

procedure TConsultaCEPModelTests.CEPInvalidoNaoChamaGatewayNemRepositorio;
var
  LDTO: TDadosEnderecoDTO;
begin
  LDTO := FModel.ConsultarCEP('123');

  Assert.AreEqual(rcCEPInvalido, LDTO.Resultado);
  Assert.AreEqual(0, FGatewayObj.Chamadas);
  Assert.AreEqual(0, FRepoObj.ChamadasSalvar);
end;

procedure TConsultaCEPModelTests.CEPSucessoChamaGatewayESalvaHistorico;
var
  LDTO: TDadosEnderecoDTO;
begin
  FGatewayObj.DTO.Resultado := rcSucesso;
  FGatewayObj.DTO.Encontrado := True;
  FGatewayObj.DTO.Logradouro := 'Rua Teste';
  FGatewayObj.DTO.Cidade := 'Joinville';
  FGatewayObj.DTO.UF := 'SC';

  LDTO := FModel.ConsultarCEP('89201000');

  Assert.AreEqual(rcSucesso, LDTO.Resultado);
  Assert.AreEqual(1, FGatewayObj.Chamadas);
  Assert.AreEqual(1, FRepoObj.ChamadasSalvar);
  Assert.AreEqual('FakeGateway', FRepoObj.Registros[0].GatewayUsado);
end;

procedure TConsultaCEPModelTests.CriarModel;
begin
  FGatewayObj := TFakeGateway.Create;
  FRepoObj := TFakeRepositorio.Create;
  FGateway := FGatewayObj;
  FRepo := FRepoObj;
  FModel := TConsultaCEPModel.Create(FGateway, FRepo);
end;

procedure TConsultaCEPModelTests.ErroDeAPIEConvertidoEmDTOEPersistido;
var
  LDTO: TDadosEnderecoDTO;
begin
  FGatewayObj.DeveFalhar := True;

  LDTO := FModel.ConsultarCEP('89201000');

  Assert.AreEqual(rcErroAPI, LDTO.Resultado);
  Assert.AreEqual(1, FGatewayObj.Chamadas);
  Assert.AreEqual(1, FRepoObj.ChamadasSalvar);
end;

procedure TConsultaCEPModelTests.FalhaAoSalvarNaoImpedeRetornoDoDTO;
var
  LDTO: TDadosEnderecoDTO;
begin
  FGatewayObj.DTO.Resultado := rcSucesso;
  FGatewayObj.DTO.Encontrado := True;
  FGatewayObj.DTO.Cidade := 'Joinville';
  FRepoObj.DeveFalharAoSalvar := True;

  LDTO := FModel.ConsultarCEP('89201000');

  Assert.AreEqual(rcSucesso, LDTO.Resultado);
  Assert.AreEqual(1, FRepoObj.ChamadasSalvar);
end;

procedure TConsultaCEPModelTests.Setup;
begin
  CriarModel;
end;

initialization
  TDUnitX.RegisterTestFixture(TConsultaCEPModelTests);

end.
