unit ConsultaCEP.View.Main;

interface

uses
  ConsultaCEP.DTO,
  ConsultaCEP.Interfaces,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Grids,
  Vcl.StdCtrls;

type
  TFormMain = class(TForm, IConsultaCEPView)
    edtCEP: TEdit;
    btnBuscar: TButton;
    btnHistorico: TButton;
    lblStatus: TLabel;
    lblLogradouro: TLabel;
    lblBairro: TLabel;
    lblCidade: TLabel;
    lblUF: TLabel;
    lblComplemento: TLabel;
    gridHistorico: TStringGrid;
    procedure btnBuscarClick(Sender: TObject);
    procedure btnHistoricoClick(Sender: TObject);
    procedure edtCEPKeyPress(Sender: TObject; var Key: Char);
  strict private
    [weak] FController: IConsultaCEPController;
    procedure PrepararGrid;
    procedure LimparEndereco;
  public
    procedure SetController(const AController: IConsultaCEPController);
    procedure AtualizarEndereco(const ADTO: TDadosEnderecoDTO);
    procedure ExibirMensagem(const AMensagem: string);
    procedure ExibirHistorico(const ARegistros: TArray<TConsultaCEPRecord>);
    procedure SetCarregando(AValor: Boolean);
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

uses
  Spring,
  System.SysUtils;

procedure TFormMain.AtualizarEndereco(const ADTO: TDadosEnderecoDTO);
begin
  lblStatus.Caption := ADTO.Resultado.ToUserMessage;
  lblLogradouro.Caption := 'Logradouro: ' + ADTO.Logradouro;
  lblBairro.Caption := 'Bairro: ' + ADTO.Bairro;
  lblCidade.Caption := 'Cidade: ' + ADTO.Cidade;
  lblUF.Caption := 'UF: ' + ADTO.UF;
  lblComplemento.Caption := 'Complemento: ' + ADTO.Complemento;
end;

procedure TFormMain.btnBuscarClick(Sender: TObject);
begin
  if FController <> nil then
    FController.ConsultarCEP(edtCEP.Text);
end;

procedure TFormMain.btnHistoricoClick(Sender: TObject);
begin
  if FController <> nil then
    FController.SolicitarHistorico;
end;

procedure TFormMain.edtCEPKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnBuscarClick(Sender);
    Exit;
  end;

  if not CharInSet(Key, ['0'..'9', #8]) then
    Key := #0;
end;

procedure TFormMain.ExibirHistorico(
  const ARegistros: TArray<TConsultaCEPRecord>);
var
  I: Integer;
begin
  PrepararGrid;
  if Length(ARegistros) = 0 then
  begin
    lblStatus.Caption := 'Nenhuma consulta registrada.';
    Exit;
  end;

  gridHistorico.RowCount := Length(ARegistros) + 1;
  for I := 0 to High(ARegistros) do
  begin
    gridHistorico.Cells[0, I + 1] := ARegistros[I].CEP;
    gridHistorico.Cells[1, I + 1] := FormatDateTime('dd/mm/yyyy hh:nn:ss',
      ARegistros[I].DataHora);
    gridHistorico.Cells[2, I + 1] := ARegistros[I].Cidade;
    gridHistorico.Cells[3, I + 1] := ARegistros[I].Resultado.ToDatabaseValue;
    gridHistorico.Cells[4, I + 1] := ARegistros[I].GatewayUsado;
  end;
end;

procedure TFormMain.ExibirMensagem(const AMensagem: string);
begin
  lblStatus.Caption := AMensagem;
  if not SameText(AMensagem, 'Nenhuma consulta registrada.') then
    LimparEndereco;
end;

procedure TFormMain.LimparEndereco;
begin
  lblLogradouro.Caption := 'Logradouro:';
  lblBairro.Caption := 'Bairro:';
  lblCidade.Caption := 'Cidade:';
  lblUF.Caption := 'UF:';
  lblComplemento.Caption := 'Complemento:';
end;

procedure TFormMain.PrepararGrid;
begin
  gridHistorico.ColCount := 5;
  gridHistorico.FixedRows := 1;
  gridHistorico.RowCount := 2;
  gridHistorico.Cells[0, 0] := 'CEP';
  gridHistorico.Cells[1, 0] := 'Data/Hora';
  gridHistorico.Cells[2, 0] := 'Cidade';
  gridHistorico.Cells[3, 0] := 'Resultado';
  gridHistorico.Cells[4, 0] := 'Gateway';
  gridHistorico.ColWidths[0] := 90;
  gridHistorico.ColWidths[1] := 150;
  gridHistorico.ColWidths[2] := 180;
  gridHistorico.ColWidths[3] := 130;
  gridHistorico.ColWidths[4] := 110;
end;

procedure TFormMain.SetCarregando(AValor: Boolean);
begin
  btnBuscar.Enabled := not AValor;
  btnHistorico.Enabled := not AValor;
  edtCEP.Enabled := not AValor;
  if AValor then
    lblStatus.Caption := 'Consultando...';
end;

procedure TFormMain.SetController(
  const AController: IConsultaCEPController);
begin
  Guard.CheckNotNull(AController, 'AController');
  FController := AController;
  PrepararGrid;
end;

end.
