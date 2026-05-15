unit ConsultaCEP.Gateway.BrasilAPI;

interface

uses
  ConsultaCEP.DTO,
  ConsultaCEP.Interfaces,
  System.Net.HttpClient;

type
  TBrasilAPIAdapter = class(TInterfacedObject, IGatewayEndereco)
  private
    FURLBase: string;
    FHttp: THTTPClient;
  public
    constructor Create(const AURLBase: string = 'https://brasilapi.com.br/api/cep/v1');
    destructor Destroy; override;
    function Nome: string;
    function BuscarEndereco(const ACEP: string): TDadosEnderecoDTO;
  end;

implementation

uses
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

constructor TBrasilAPIAdapter.Create(const AURLBase: string);
begin
  inherited Create;
  FURLBase := NormalizeURLBase(AURLBase);
  FHttp := THTTPClient.Create;
  FHttp.ConnectionTimeout := 10000;
  FHttp.ResponseTimeout := 10000;
end;

destructor TBrasilAPIAdapter.Destroy;
begin
  FHttp.Free;
  inherited;
end;

function TBrasilAPIAdapter.BuscarEndereco(
  const ACEP: string): TDadosEnderecoDTO;
var
  LResponse: IHTTPResponse;
  LJSON: TJSONObject;
begin
  LResponse := FHttp.Get(Format('%s/%s', [FURLBase, ACEP]));
  if LResponse.StatusCode = 404 then
  begin
    Result := Default(TDadosEnderecoDTO);
    Result.CEP := ACEP;
    Result.Encontrado := False;
    Result.Resultado := rcCEPNaoEncontrado;
    Result.MensagemErro := 'CEP nao encontrado.';
    Exit;
  end;
  if LResponse.StatusCode <> 200 then
    raise Exception.CreateFmt('BrasilAPI retornou HTTP %d', [LResponse.StatusCode]);

  LJSON := TJSONObject.ParseJSONValue(LResponse.ContentAsString(TEncoding.UTF8)) as TJSONObject;
  try
    if LJSON = nil then
      raise Exception.Create('Resposta JSON invalida da BrasilAPI');

    Result := Default(TDadosEnderecoDTO);
    Result.CEP := ACEP;
    Result.Encontrado := True;
    Result.Resultado := rcSucesso;
    Result.Logradouro := JSONString(LJSON, 'street');
    Result.Bairro := JSONString(LJSON, 'neighborhood');
    Result.Cidade := JSONString(LJSON, 'city');
    Result.UF := JSONString(LJSON, 'state');
    Result.Complemento := JSONString(LJSON, 'service');
  finally
    LJSON.Free;
  end;
end;

function TBrasilAPIAdapter.Nome: string;
begin
  Result := 'BrasilAPI';
end;

end.
