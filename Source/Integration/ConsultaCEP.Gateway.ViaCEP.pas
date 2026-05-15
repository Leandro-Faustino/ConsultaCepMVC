unit ConsultaCEP.Gateway.ViaCEP;

interface

uses
  ConsultaCEP.DTO,
  ConsultaCEP.Interfaces,
  System.Net.HttpClient;

type
  TViaCEPAdapter = class(TInterfacedObject, IGatewayEndereco)
  private
    FURLBase: string;
    FHttp: THTTPClient;
  public
    constructor Create(const AURLBase: string = 'https://viacep.com.br/ws');
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

constructor TViaCEPAdapter.Create(const AURLBase: string);
begin
  inherited Create;
  FURLBase := NormalizeURLBase(AURLBase);
  FHttp := THTTPClient.Create;
  FHttp.ConnectionTimeout := 10000;
  FHttp.ResponseTimeout := 10000;
end;

destructor TViaCEPAdapter.Destroy;
begin
  FHttp.Free;
  inherited;
end;

function TViaCEPAdapter.BuscarEndereco(const ACEP: string): TDadosEnderecoDTO;
var
  LResponse: IHTTPResponse;
  LJSON: TJSONObject;
begin
  LResponse := FHttp.Get(Format('%s/%s/json/', [FURLBase, ACEP]));
  if LResponse.StatusCode <> 200 then
    raise Exception.CreateFmt('ViaCEP retornou HTTP %d', [LResponse.StatusCode]);

  LJSON := TJSONObject.ParseJSONValue(LResponse.ContentAsString(TEncoding.UTF8)) as TJSONObject;
  try
    if LJSON = nil then
      raise Exception.Create('Resposta JSON invalida da ViaCEP');

    Result := Default(TDadosEnderecoDTO);
    Result.CEP := ACEP;
    if SameText(JSONString(LJSON, 'erro'), 'true') then
    begin
      Result.Encontrado := False;
      Result.Resultado := rcCEPNaoEncontrado;
      Result.MensagemErro := 'CEP nao encontrado.';
      Exit;
    end;

    Result.Encontrado := True;
    Result.Resultado := rcSucesso;
    Result.Logradouro := JSONString(LJSON, 'logradouro');
    Result.Bairro := JSONString(LJSON, 'bairro');
    Result.Cidade := JSONString(LJSON, 'localidade');
    Result.UF := JSONString(LJSON, 'uf');
    Result.Complemento := JSONString(LJSON, 'complemento');
  finally
    LJSON.Free;
  end;
end;

function TViaCEPAdapter.Nome: string;
begin
  Result := 'ViaCEP';
end;

end.
