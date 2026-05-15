unit ConsultaCEP.DTO;

interface

uses
  System.SysUtils;

type
  TResultadoConsulta = (rcSucesso, rcCEPNaoEncontrado, rcErroAPI, rcCEPInvalido);

  TResultadoConsultaHelper = record helper for TResultadoConsulta
    function ToDatabaseValue: string;
    function ToUserMessage: string;
    class function FromDatabaseValue(const AValue: string): TResultadoConsulta; static;
  end;

  TDadosEnderecoDTO = record
    CEP: string;
    Logradouro: string;
    Bairro: string;
    Cidade: string;
    UF: string;
    Complemento: string;
    Encontrado: Boolean;
    Resultado: TResultadoConsulta;
    MensagemErro: string;
    class function CEPInvalido(const ACEP: string): TDadosEnderecoDTO; static;
    class function ErroAPI(const ACEP, AMensagem: string): TDadosEnderecoDTO; static;
  end;

  TConsultaCEPRecord = record
    ID: Int64;
    CEP: string;
    DataHora: TDateTime;
    Resultado: TResultadoConsulta;
    Logradouro: string;
    Bairro: string;
    Cidade: string;
    UF: string;
    Complemento: string;
    GatewayUsado: string;
    class function FromDTO(const ADTO: TDadosEnderecoDTO;
      const AGatewayUsado: string): TConsultaCEPRecord; static;
  end;

function ResultadoConsultaFromDatabaseValue(
  const AValue: string): TResultadoConsulta;

implementation

class function TDadosEnderecoDTO.CEPInvalido(
  const ACEP: string): TDadosEnderecoDTO;
begin
  Result := Default(TDadosEnderecoDTO);
  Result.CEP := ACEP;
  Result.Encontrado := False;
  Result.Resultado := rcCEPInvalido;
  Result.MensagemErro := 'CEP invalido. Informe 8 digitos numericos.';
end;

class function TDadosEnderecoDTO.ErroAPI(const ACEP,
  AMensagem: string): TDadosEnderecoDTO;
begin
  Result := Default(TDadosEnderecoDTO);
  Result.CEP := ACEP;
  Result.Encontrado := False;
  Result.Resultado := rcErroAPI;
  if AMensagem.Trim.IsEmpty then
    Result.MensagemErro := 'Servico temporariamente indisponivel. Tente novamente mais tarde.'
  else
    Result.MensagemErro := AMensagem;
end;

class function TConsultaCEPRecord.FromDTO(const ADTO: TDadosEnderecoDTO;
  const AGatewayUsado: string): TConsultaCEPRecord;
begin
  Result := Default(TConsultaCEPRecord);
  Result.CEP := ADTO.CEP;
  Result.DataHora := Now;
  Result.Resultado := ADTO.Resultado;
  Result.Logradouro := ADTO.Logradouro;
  Result.Bairro := ADTO.Bairro;
  Result.Cidade := ADTO.Cidade;
  Result.UF := ADTO.UF;
  Result.Complemento := ADTO.Complemento;
  Result.GatewayUsado := AGatewayUsado;
end;

function ResultadoConsultaFromDatabaseValue(
  const AValue: string): TResultadoConsulta;
var
  LValue: string;
begin
  LValue := AValue.Trim.ToUpper;
  if LValue = 'SUCESSO' then
    Exit(rcSucesso);
  if LValue = 'NAO_ENCONTRADO' then
    Exit(rcCEPNaoEncontrado);
  if LValue = 'CEP_INVALIDO' then
    Exit(rcCEPInvalido);
  Result := rcErroAPI;
end;

class function TResultadoConsultaHelper.FromDatabaseValue(
  const AValue: string): TResultadoConsulta;
begin
  Result := ResultadoConsultaFromDatabaseValue(AValue);
end;

function TResultadoConsultaHelper.ToDatabaseValue: string;
begin
  case Self of
    rcSucesso: Result := 'SUCESSO';
    rcCEPNaoEncontrado: Result := 'NAO_ENCONTRADO';
    rcCEPInvalido: Result := 'CEP_INVALIDO';
  else
    Result := 'ERRO_API';
  end;
end;

function TResultadoConsultaHelper.ToUserMessage: string;
begin
  case Self of
    rcSucesso: Result := 'Endereco encontrado.';
    rcCEPNaoEncontrado: Result := 'CEP nao encontrado.';
    rcCEPInvalido: Result := 'CEP invalido. Informe 8 digitos numericos.';
  else
    Result := 'Servico temporariamente indisponivel. Tente novamente mais tarde.';
  end;
end;

end.
