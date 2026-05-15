object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'ConsultaCEP MVC'
  ClientHeight = 481
  ClientWidth = 744
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    744
    481)
  PixelsPerInch = 96
  TextHeight = 13
  object lblTitulo: TLabel
    Left = 16
    Top = 16
    Width = 163
    Height = 25
    Caption = 'Consulta de CEP'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblStatus: TLabel
    Left = 16
    Top = 92
    Width = 704
    Height = 16
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Pronto.'
  end
  object lblLogradouro: TLabel
    Left = 16
    Top = 128
    Width = 704
    Height = 16
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Logradouro:'
  end
  object lblBairro: TLabel
    Left = 16
    Top = 152
    Width = 704
    Height = 16
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Bairro:'
  end
  object lblCidade: TLabel
    Left = 16
    Top = 176
    Width = 704
    Height = 16
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Cidade:'
  end
  object lblUF: TLabel
    Left = 16
    Top = 200
    Width = 704
    Height = 16
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'UF:'
  end
  object lblComplemento: TLabel
    Left = 16
    Top = 224
    Width = 704
    Height = 16
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Complemento:'
  end
  object edtCEP: TEdit
    Left = 16
    Top = 56
    Width = 160
    Height = 21
    MaxLength = 8
    NumbersOnly = True
    TabOrder = 0
    TextHint = 'Digite 8 numeros'
    OnKeyPress = edtCEPKeyPress
  end
  object btnBuscar: TButton
    Left = 184
    Top = 54
    Width = 96
    Height = 25
    Caption = 'Buscar'
    TabOrder = 1
    OnClick = btnBuscarClick
  end
  object btnHistorico: TButton
    Left = 288
    Top = 54
    Width = 120
    Height = 25
    Caption = 'Ver historico'
    TabOrder = 2
    OnClick = btnHistoricoClick
  end
  object gridHistorico: TStringGrid
    Left = 16
    Top = 264
    Width = 704
    Height = 193
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 5
    FixedCols = 0
    RowCount = 2
    TabOrder = 3
  end
end
