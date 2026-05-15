unit ConsultaCEP.Repository.FireDAC;

interface

uses
  ConsultaCEP.DTO,
  ConsultaCEP.Interfaces,
  FireDAC.Comp.Client;

type
  TRepositorioConsultaFireDAC = class(TInterfacedObject, IRepositorioConsulta)
  private
    FConnection: TFDConnection;
  public
    constructor Create(AConnection: TFDConnection);
    function Salvar(const AConsulta: TConsultaCEPRecord): Int64;
    function ListarTodos: TArray<TConsultaCEPRecord>;
  end;

implementation

uses
  System.SysUtils,
  FireDAC.Stan.Param;

constructor TRepositorioConsultaFireDAC.Create(AConnection: TFDConnection);
begin
  inherited Create;
  if AConnection = nil then
    raise EArgumentNilException.Create('AConnection nao pode ser nil');
  FConnection := AConnection;
end;

function TRepositorioConsultaFireDAC.ListarTodos: TArray<TConsultaCEPRecord>;
var
  LQuery: TFDQuery;
  LItem: TConsultaCEPRecord;
begin
  SetLength(Result, 0);
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'SELECT * FROM SP_LISTAR_HISTORICO';
    LQuery.Open;
    while not LQuery.Eof do
    begin
      LItem := Default(TConsultaCEPRecord);
      LItem.ID := LQuery.FieldByName('R_ID').AsLargeInt;
      LItem.CEP := LQuery.FieldByName('R_CEP').AsString;
      LItem.DataHora := LQuery.FieldByName('R_DATA_HORA').AsDateTime;
      LItem.Resultado := ResultadoConsultaFromDatabaseValue(
        LQuery.FieldByName('R_RESULTADO').AsString);
      LItem.Logradouro := LQuery.FieldByName('R_LOGRADOURO').AsString;
      LItem.Bairro := LQuery.FieldByName('R_BAIRRO').AsString;
      LItem.Cidade := LQuery.FieldByName('R_CIDADE').AsString;
      LItem.UF := LQuery.FieldByName('R_UF').AsString;
      LItem.Complemento := LQuery.FieldByName('R_COMPLEMENTO').AsString;
      LItem.GatewayUsado := LQuery.FieldByName('R_GATEWAY_USADO').AsString;

      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := LItem;
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

function TRepositorioConsultaFireDAC.Salvar(
  const AConsulta: TConsultaCEPRecord): Int64;
var
  LProc: TFDStoredProc;
begin
  LProc := TFDStoredProc.Create(nil);
  try
    LProc.Connection := FConnection;
    LProc.StoredProcName := 'SP_SALVAR_CONSULTA';
    LProc.Prepare;
    LProc.ParamByName('P_CEP').AsString := AConsulta.CEP;
    LProc.ParamByName('P_RESULTADO').AsString := AConsulta.Resultado.ToDatabaseValue;
    LProc.ParamByName('P_LOGRADOURO').AsString := AConsulta.Logradouro;
    LProc.ParamByName('P_BAIRRO').AsString := AConsulta.Bairro;
    LProc.ParamByName('P_CIDADE').AsString := AConsulta.Cidade;
    LProc.ParamByName('P_UF').AsString := AConsulta.UF;
    LProc.ParamByName('P_COMPLEMENTO').AsString := AConsulta.Complemento;
    LProc.ParamByName('P_GATEWAY_USADO').AsString := AConsulta.GatewayUsado;
    LProc.Open;
    Result := LProc.FieldByName('P_ID').AsLargeInt;
  finally
    LProc.Free;
  end;
end;

end.
