unit ConsultaCEP.Gateway.ViaCEP;

interface

uses
  ConsultaCEP.DTO,
  ConsultaCEP.Interfaces;

type
  TViaCEPAdapter = class(TInterfacedObject, IGatewayEndereco)
  private
    FURLBase: string;
  public
    constructor Create(const AURLBase: string = 'https://viacep.com.br/ws');
    function Nome: string;
    function BuscarEndereco(const ACEP: string): TDadosEnderecoDTO;
  end;

implementation

uses
  System.Net.HttpClient,
  System.JSON,
  System.SysUtils;

function JSONString(const AObject: TJSONObject; const AName: string): string;
var
  LValue: TJSONValue;
begin
  Result := '';
  LValue := AObject.Values[AName];
  if Assigned(LValue) and not (LValue is TJSONNull) then
    Result := LValue.Value;
end;

function NormalizeURLBase(const AValue: string): string;
begin
  Result := AValue.Trim;
  while Result.EndsWith('/') do
    Delete(Result, Length(Result), 1);
end;

constructor TViaCEPAdapter.Create(const AURLBase: string);
begin
  inherited Create;
  FURLBase := NormalizeURLBase(AURLBase);
end;

function TViaCEPAdapter.BuscarEndereco(const ACEP: string): TDadosEnderecoDTO;
var
  LHttp: THTTPClient;
  LResponse: IHTTPResponse;
  LJSON: TJSONObject;
begin
  LHttp := THTTPClient.Create;
  try
    LHttp.ConnectionTimeout := 10000;
    LHttp.ResponseTimeout := 10000;
    LResponse := LHttp.Get(Format('%s/%s/json/', [FURLBase, ACEP]));
    if LResponse.StatusCode <> 200 then
      raise Exception.CreateFmt('ViaCEP retornou HTTP %d', [LResponse.StatusCode]);

    LJSON := TJSONObject.ParseJSONValue(
      LResponse.ContentAsString(TEncoding.UTF8)) as TJSONObject;
    try
      if LJSON = nil then
        raise Exception.Create('Resposta JSON invalida da ViaCEP');

      if SameText(JSONString(LJSON, 'erro'), 'true') then
        Exit(TDadosEnderecoDTO.CEPNaoEncontrado(ACEP));

      Result := Default(TDadosEnderecoDTO);
      Result.CEP := ACEP;
      Result.Resultado := rcSucesso;
      Result.Logradouro := JSONString(LJSON, 'logradouro');
      Result.Bairro := JSONString(LJSON, 'bairro');
      Result.Cidade := JSONString(LJSON, 'localidade');
      Result.UF := JSONString(LJSON, 'uf');
      Result.Complemento := JSONString(LJSON, 'complemento');
    finally
      LJSON.Free;
    end;
  finally
    LHttp.Free;
  end;
end;

function TViaCEPAdapter.Nome: string;
begin
  Result := 'ViaCEP';
end;

end.
