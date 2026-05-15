unit ConsultaCEP.Repository.FireDAC;

interface

uses
  ConsultaCEP.DTO,
  ConsultaCEP.Interfaces,
  FireDAC.Comp.Client;

type
  TConnectionFactory = reference to function: TFDConnection;

  TRepositorioConsultaFireDAC = class(TInterfacedObject, IRepositorioConsulta)
  private
    FConnectionFactory: TConnectionFactory;
  public
    constructor Create(const AConnectionFactory: TConnectionFactory);
    function Salvar(const AConsulta: TConsultaCEPRecord): Int64;
    function ListarRecentes(AMaxRegistros: Integer): TArray<TConsultaCEPRecord>;
  end;

implementation

uses
  System.SysUtils,
  FireDAC.Stan.Param;

constructor TRepositorioConsultaFireDAC.Create(
  const AConnectionFactory: TConnectionFactory);
begin
  inherited Create;
  if not Assigned(AConnectionFactory) then
    raise EArgumentNilException.Create('AConnectionFactory nao pode ser nil');
  FConnectionFactory := AConnectionFactory;
end;

function TRepositorioConsultaFireDAC.ListarRecentes(
  AMaxRegistros: Integer): TArray<TConsultaCEPRecord>;
var
  LConnection: TFDConnection;
  LQuery: TFDQuery;
  LItem: TConsultaCEPRecord;
begin
  SetLength(Result, 0);
  if AMaxRegistros <= 0 then
    Exit;

  LConnection := FConnectionFactory();
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := LConnection;
    LQuery.SQL.Text :=
      'SELECT FIRST :MAX_REGISTROS ID, CEP, DATA_HORA, RESULTADO, ' +
      'LOGRADOURO, BAIRRO, CIDADE, UF, COMPLEMENTO, GATEWAY_USADO ' +
      'FROM CONSULTA_CEP ORDER BY DATA_HORA DESC';
    LQuery.ParamByName('MAX_REGISTROS').AsInteger := AMaxRegistros;
    LQuery.Open;
    while not LQuery.Eof do
    begin
      LItem := Default(TConsultaCEPRecord);
      LItem.ID := LQuery.FieldByName('ID').AsLargeInt;
      LItem.CEP := LQuery.FieldByName('CEP').AsString;
      LItem.DataHora := LQuery.FieldByName('DATA_HORA').AsDateTime;
      LItem.Resultado := ResultadoConsultaFromDatabaseValue(
        LQuery.FieldByName('RESULTADO').AsString);
      LItem.Logradouro := LQuery.FieldByName('LOGRADOURO').AsString;
      LItem.Bairro := LQuery.FieldByName('BAIRRO').AsString;
      LItem.Cidade := LQuery.FieldByName('CIDADE').AsString;
      LItem.UF := LQuery.FieldByName('UF').AsString;
      LItem.Complemento := LQuery.FieldByName('COMPLEMENTO').AsString;
      LItem.GatewayUsado := LQuery.FieldByName('GATEWAY_USADO').AsString;

      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := LItem;
      LQuery.Next;
    end;
  finally
    LQuery.Free;
    LConnection.Free;
  end;
end;

function TRepositorioConsultaFireDAC.Salvar(
  const AConsulta: TConsultaCEPRecord): Int64;
var
  LConnection: TFDConnection;
  LProc: TFDStoredProc;
begin
  LConnection := FConnectionFactory();
  LProc := TFDStoredProc.Create(nil);
  try
    LProc.Connection := LConnection;
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
    LConnection.Free;
  end;
end;

end.
