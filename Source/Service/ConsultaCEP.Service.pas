unit ConsultaCEP.Service;

interface

uses
  ConsultaCEP.DTO,
  ConsultaCEP.Interfaces;

type
  TConsultaCEPService = class(TInterfacedObject, IConsultaCEPService)
  strict private
    FGateway: IGatewayEndereco;
    FRepositorio: IRepositorioConsulta;
    FLogger: ILogger;
    procedure TentarSalvarHistorico(const ADTO: TDadosEnderecoDTO);
  public
    constructor Create(const AGateway: IGatewayEndereco;
      const ARepositorio: IRepositorioConsulta; const ALogger: ILogger);
    function ConsultarCEP(const ACEP: string): TDadosEnderecoDTO;
    function ObterHistorico(AMaxRegistros: Integer): TArray<TConsultaCEPRecord>;
  end;

implementation

uses
  ConsultaCEP.CEP,
  Spring,
  System.SysUtils;

constructor TConsultaCEPService.Create(const AGateway: IGatewayEndereco;
  const ARepositorio: IRepositorioConsulta; const ALogger: ILogger);
begin
  inherited Create;
  Guard.CheckNotNull(AGateway, 'AGateway');
  Guard.CheckNotNull(ARepositorio, 'ARepositorio');
  Guard.CheckNotNull(ALogger, 'ALogger');
  FGateway := AGateway;
  FRepositorio := ARepositorio;
  FLogger := ALogger;
end;

function TConsultaCEPService.ConsultarCEP(
  const ACEP: string): TDadosEnderecoDTO;
var
  LCEP: TCEP;
begin
  if not TCEP.TryParse(ACEP, LCEP) then
    Exit(TDadosEnderecoDTO.CEPInvalido(ACEP.Trim));

  try
    Result := FGateway.BuscarEndereco(LCEP.Valor);
  except
    on E: Exception do
    begin
      Result := TDadosEnderecoDTO.ErroAPI(LCEP.Valor, E.Message);
      FLogger.Erro('Falha ao consultar gateway ' + FGateway.Nome + ': ' + E.Message);
    end;
  end;

  TentarSalvarHistorico(Result);
end;

function TConsultaCEPService.ObterHistorico(
  AMaxRegistros: Integer): TArray<TConsultaCEPRecord>;
begin
  Result := FRepositorio.ListarRecentes(AMaxRegistros);
end;

procedure TConsultaCEPService.TentarSalvarHistorico(
  const ADTO: TDadosEnderecoDTO);
var
  LRegistro: TConsultaCEPRecord;
begin
  if ADTO.Resultado = rcCEPInvalido then
    Exit;

  LRegistro := TConsultaCEPRecord.FromDTO(ADTO, FGateway.Nome);
  try
    FRepositorio.Salvar(LRegistro);
  except
    on E: Exception do
      FLogger.Erro('Falha ao persistir consulta: ' + E.Message);
  end;
end;

end.
