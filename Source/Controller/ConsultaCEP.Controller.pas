unit ConsultaCEP.Controller;

interface

uses
  ConsultaCEP.DTO,
  ConsultaCEP.Interfaces;

type
  TConsultaCEPController = class(TInterfacedObject, IConsultaCEPController)
  private
    FView: IConsultaCEPView;
    FModel: IConsultaCEPModel;
  public
    constructor Create(const AView: IConsultaCEPView;
      const AModel: IConsultaCEPModel);
    procedure ConsultarCEP(const ACEP: string);
    procedure SolicitarHistorico;
  end;

implementation

uses
  System.Classes,
  System.SysUtils,
  System.Threading;

constructor TConsultaCEPController.Create(const AView: IConsultaCEPView;
  const AModel: IConsultaCEPModel);
begin
  inherited Create;
  if AView = nil then
    raise EArgumentNilException.Create('AView nao pode ser nil');
  if AModel = nil then
    raise EArgumentNilException.Create('AModel nao pode ser nil');

  FView := AView;
  FModel := AModel;
end;

procedure TConsultaCEPController.ConsultarCEP(const ACEP: string);
begin
  FView.SetCarregando(True);

  TTask.Run(
    procedure
    var
      LDTO: TDadosEnderecoDTO;
      LRegistros: TArray<TConsultaCEPRecord>;
      LMensagem: string;
      LErro: string;
    begin
      try
        LDTO := FModel.ConsultarCEP(ACEP);
        LRegistros := FModel.ObterHistorico;
        LMensagem := LDTO.MensagemErro;
        if LMensagem.Trim.IsEmpty then
          LMensagem := LDTO.Resultado.ToUserMessage;
      except
        on E: Exception do
          LErro := E.Message;
      end;

      TThread.Queue(nil,
        procedure
        begin
          try
            if not LErro.Trim.IsEmpty then
              FView.ExibirMensagem('Erro ao consultar CEP: ' + LErro)
            else
            begin
              if LDTO.Resultado = rcSucesso then
                FView.AtualizarEndereco(LDTO)
              else
                FView.ExibirMensagem(LMensagem);

              FView.ExibirHistorico(LRegistros);
            end;
          finally
            FView.SetCarregando(False);
          end;
        end);
    end);
end;

procedure TConsultaCEPController.SolicitarHistorico;
begin
  FView.SetCarregando(True);

  TTask.Run(
    procedure
    var
      LRegistros: TArray<TConsultaCEPRecord>;
      LErro: string;
    begin
      try
        LRegistros := FModel.ObterHistorico;
      except
        on E: Exception do
          LErro := E.Message;
      end;

      TThread.Queue(nil,
        procedure
        begin
          try
            if LErro.Trim.IsEmpty then
              FView.ExibirHistorico(LRegistros)
            else
              FView.ExibirMensagem('Erro ao carregar historico: ' + LErro);
          finally
            FView.SetCarregando(False);
          end;
        end);
    end);
end;

end.
