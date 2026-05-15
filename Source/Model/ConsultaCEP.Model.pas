unit ConsultaCEP.Model;

interface

uses
  ConsultaCEP.DTO,
  ConsultaCEP.Interfaces;

type
  TConsultaCEPModel = class(TInterfacedObject, IConsultaCEPModel)
  private
    FGateway: IGatewayEndereco;
    FRepositorio: IRepositorioConsulta;
    class function ValidarCEP(const ACEP: string): Boolean; static;
    procedure TentarSalvarHistorico(const ADTO: TDadosEnderecoDTO);
  public
    constructor Create(const AGateway: IGatewayEndereco;
      const ARepositorio: IRepositorioConsulta);
    function ConsultarCEP(const ACEP: string): TDadosEnderecoDTO;
    function ObterHistorico: TArray<TConsultaCEPRecord>;
  end;

implementation

uses
  System.SysUtils,
  System.RegularExpressions;

constructor TConsultaCEPModel.Create(const AGateway: IGatewayEndereco;
  const ARepositorio: IRepositorioConsulta);
begin
  inherited Create;
  if AGateway = nil then
    raise EArgumentNilException.Create('AGateway nao pode ser nil');
  if ARepositorio = nil then
    raise EArgumentNilException.Create('ARepositorio nao pode ser nil');

  FGateway := AGateway;
  FRepositorio := ARepositorio;
end;

function TConsultaCEPModel.ConsultarCEP(const ACEP: string): TDadosEnderecoDTO;
var
  LCEP: string;
begin
  LCEP := ACEP.Trim;
  if not ValidarCEP(LCEP) then
    Exit(TDadosEnderecoDTO.CEPInvalido(LCEP));

  try
    Result := FGateway.BuscarEndereco(LCEP);
  except
    on E: Exception do
      Result := TDadosEnderecoDTO.ErroAPI(LCEP, E.Message);
  end;

  TentarSalvarHistorico(Result);
end;

function TConsultaCEPModel.ObterHistorico: TArray<TConsultaCEPRecord>;
begin
  Result := FRepositorio.ListarTodos;
end;

procedure TConsultaCEPModel.TentarSalvarHistorico(const ADTO: TDadosEnderecoDTO);
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
    begin
      // A consulta ja deve voltar para a tela mesmo quando o historico falhar.
    end;
  end;
end;

class function TConsultaCEPModel.ValidarCEP(const ACEP: string): Boolean;
begin
  Result := TRegEx.IsMatch(ACEP, '^\d{8}$');
end;

end.

