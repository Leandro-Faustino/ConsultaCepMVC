unit ConsultaCEP.Controller;

interface

uses
  ConsultaCEP.DTO,
  ConsultaCEP.Interfaces;

type
  TConsultaCEPController = class(TInterfacedObject, IConsultaCEPController)
  private
    FView: IConsultaCEPView;
    FService: IConsultaCEPService;
    FLogger: ILogger;
  public
    constructor Create(const AView: IConsultaCEPView;
      const AService: IConsultaCEPService; const ALogger: ILogger);
    procedure ConsultarCEP(const ACEP: string);
    procedure SolicitarHistorico;
  end;

implementation

uses
  Spring,
  System.Classes,
  System.SysUtils,
  System.Threading;

constructor TConsultaCEPController.Create(const AView: IConsultaCEPView;
  const AService: IConsultaCEPService; const ALogger: ILogger);
begin
  inherited Create;
  Guard.CheckNotNull(AView, 'AView');
  Guard.CheckNotNull(AService, 'AService');
  Guard.CheckNotNull(ALogger, 'ALogger');
  FView := AView;
  FService := AService;
  FLogger := ALogger;
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
        LDTO := FService.ConsultarCEP(ACEP);
        LRegistros := FService.ObterHistorico(10000);
        LMensagem := LDTO.MensagemErro;
        if LMensagem.Trim.IsEmpty then
          LMensagem := LDTO.Resultado.ToUserMessage;
      except
        on E: Exception do
        begin
          LErro := E.Message;
          FLogger.Erro('Erro inesperado no controller: ' + E.Message);
        end;
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
        LRegistros := FService.ObterHistorico(10000);
      except
        on E: Exception do
        begin
          LErro := E.Message;
          FLogger.Erro('Erro ao carregar historico: ' + E.Message);
        end;
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
