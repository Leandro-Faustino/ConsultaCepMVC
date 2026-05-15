unit ConsultaCEP.View.Main;

interface

uses
  ConsultaCEP.DTO,
  ConsultaCEP.Interfaces,
  System.Classes,
  System.UITypes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Grids,
  Vcl.StdCtrls;

type
  TFormMain = class(TForm, IConsultaCEPView)
  private
    FController: IConsultaCEPController;
    FCEP: TEdit;
    FBuscar: TButton;
    FHistorico: TButton;
    FStatus: TLabel;
    FLogradouro: TLabel;
    FBairro: TLabel;
    FCidade: TLabel;
    FUF: TLabel;
    FComplemento: TLabel;
    FGrid: TStringGrid;
    procedure BuscarClick(Sender: TObject);
    procedure HistoricoClick(Sender: TObject);
    procedure CEPKeyPress(Sender: TObject; var Key: Char);
    procedure CEPKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CriarControles;
    procedure PrepararGrid;
    procedure LimparEndereco;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetController(const AController: IConsultaCEPController);
    procedure AtualizarEndereco(const ADTO: TDadosEnderecoDTO);
    procedure ExibirMensagem(const AMensagem: string);
    procedure ExibirHistorico(const ARegistros: TArray<TConsultaCEPRecord>);
    procedure SetCarregando(AValor: Boolean);
  end;

var
  FormMain: TFormMain;

implementation

uses
  System.SysUtils,
  Winapi.Windows;

constructor TFormMain.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Caption := 'ConsultaCEP MVC';
  Width := 760;
  Height := 520;
  Position := poScreenCenter;
  CriarControles;
  PrepararGrid;
end;

procedure TFormMain.AtualizarEndereco(const ADTO: TDadosEnderecoDTO);
begin
  FStatus.Caption := ADTO.Resultado.ToUserMessage;
  FLogradouro.Caption := 'Logradouro: ' + ADTO.Logradouro;
  FBairro.Caption := 'Bairro: ' + ADTO.Bairro;
  FCidade.Caption := 'Cidade: ' + ADTO.Cidade;
  FUF.Caption := 'UF: ' + ADTO.UF;
  FComplemento.Caption := 'Complemento: ' + ADTO.Complemento;
end;

procedure TFormMain.BuscarClick(Sender: TObject);
begin
  if FController <> nil then
    FController.ConsultarCEP(FCEP.Text);
end;

procedure TFormMain.CEPKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    BuscarClick(Sender);
  end;
end;

procedure TFormMain.CEPKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', #8]) then
    Key := #0;
end;

procedure TFormMain.CriarControles;
var
  LTitulo: TLabel;
begin
  LTitulo := TLabel.Create(Self);
  LTitulo.Parent := Self;
  LTitulo.Caption := 'Consulta de CEP';
  LTitulo.Left := 16;
  LTitulo.Top := 16;
  LTitulo.Font.Size := 16;
  LTitulo.Font.Style := [TFontStyle.fsBold];

  FCEP := TEdit.Create(Self);
  FCEP.Parent := Self;
  FCEP.Left := 16;
  FCEP.Top := 56;
  FCEP.Width := 160;
  FCEP.MaxLength := 8;
  FCEP.TextHint := 'Digite 8 numeros';
  FCEP.OnKeyPress := CEPKeyPress;
  FCEP.OnKeyDown := CEPKeyDown;

  FBuscar := TButton.Create(Self);
  FBuscar.Parent := Self;
  FBuscar.Left := 184;
  FBuscar.Top := 54;
  FBuscar.Width := 96;
  FBuscar.Caption := 'Buscar';
  FBuscar.OnClick := BuscarClick;

  FHistorico := TButton.Create(Self);
  FHistorico.Parent := Self;
  FHistorico.Left := 288;
  FHistorico.Top := 54;
  FHistorico.Width := 120;
  FHistorico.Caption := 'Ver historico';
  FHistorico.OnClick := HistoricoClick;

  FStatus := TLabel.Create(Self);
  FStatus.Parent := Self;
  FStatus.Left := 16;
  FStatus.Top := 92;
  FStatus.Width := 700;
  FStatus.Caption := 'Pronto.';

  FLogradouro := TLabel.Create(Self);
  FLogradouro.Parent := Self;
  FLogradouro.Left := 16;
  FLogradouro.Top := 128;
  FLogradouro.Width := 700;

  FBairro := TLabel.Create(Self);
  FBairro.Parent := Self;
  FBairro.Left := 16;
  FBairro.Top := 152;
  FBairro.Width := 700;

  FCidade := TLabel.Create(Self);
  FCidade.Parent := Self;
  FCidade.Left := 16;
  FCidade.Top := 176;
  FCidade.Width := 700;

  FUF := TLabel.Create(Self);
  FUF.Parent := Self;
  FUF.Left := 16;
  FUF.Top := 200;
  FUF.Width := 700;

  FComplemento := TLabel.Create(Self);
  FComplemento.Parent := Self;
  FComplemento.Left := 16;
  FComplemento.Top := 224;
  FComplemento.Width := 700;

  FGrid := TStringGrid.Create(Self);
  FGrid.Parent := Self;
  FGrid.Left := 16;
  FGrid.Top := 264;
  FGrid.Width := 710;
  FGrid.Height := 200;
  FGrid.Anchors := [akLeft, akTop, akRight, akBottom];
end;

procedure TFormMain.ExibirHistorico(
  const ARegistros: TArray<TConsultaCEPRecord>);
var
  I: Integer;
begin
  PrepararGrid;
  if Length(ARegistros) = 0 then
  begin
    FStatus.Caption := 'Nenhuma consulta registrada.';
    Exit;
  end;

  FGrid.RowCount := Length(ARegistros) + 1;
  for I := 0 to High(ARegistros) do
  begin
    FGrid.Cells[0, I + 1] := ARegistros[I].CEP;
    FGrid.Cells[1, I + 1] := FormatDateTime('dd/mm/yyyy hh:nn:ss',
      ARegistros[I].DataHora);
    FGrid.Cells[2, I + 1] := ARegistros[I].Cidade;
    FGrid.Cells[3, I + 1] := ARegistros[I].Resultado.ToDatabaseValue;
    FGrid.Cells[4, I + 1] := ARegistros[I].GatewayUsado;
  end;
end;

procedure TFormMain.ExibirMensagem(const AMensagem: string);
begin
  FStatus.Caption := AMensagem;
  if not SameText(AMensagem, 'Nenhuma consulta registrada.') then
    LimparEndereco;
end;

procedure TFormMain.HistoricoClick(Sender: TObject);
begin
  if FController <> nil then
    FController.SolicitarHistorico;
end;

procedure TFormMain.LimparEndereco;
begin
  FLogradouro.Caption := 'Logradouro:';
  FBairro.Caption := 'Bairro:';
  FCidade.Caption := 'Cidade:';
  FUF.Caption := 'UF:';
  FComplemento.Caption := 'Complemento:';
end;

procedure TFormMain.PrepararGrid;
begin
  FGrid.ColCount := 5;
  FGrid.FixedRows := 1;
  FGrid.RowCount := 2;
  FGrid.Cells[0, 0] := 'CEP';
  FGrid.Cells[1, 0] := 'Data/Hora';
  FGrid.Cells[2, 0] := 'Cidade';
  FGrid.Cells[3, 0] := 'Resultado';
  FGrid.Cells[4, 0] := 'Gateway';
  FGrid.ColWidths[0] := 90;
  FGrid.ColWidths[1] := 150;
  FGrid.ColWidths[2] := 180;
  FGrid.ColWidths[3] := 130;
  FGrid.ColWidths[4] := 110;
end;

procedure TFormMain.SetCarregando(AValor: Boolean);
begin
  FBuscar.Enabled := not AValor;
  FHistorico.Enabled := not AValor;
  FCEP.Enabled := not AValor;
  if AValor then
    FStatus.Caption := 'Consultando...';
end;

procedure TFormMain.SetController(
  const AController: IConsultaCEPController);
begin
  if AController = nil then
    raise EArgumentNilException.Create('AController nao pode ser nil');
  FController := AController;
end;

end.
