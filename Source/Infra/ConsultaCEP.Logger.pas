unit ConsultaCEP.Logger;

interface

uses
  ConsultaCEP.Interfaces;

type
  TNullLogger = class(TInterfacedObject, ILogger)
  public
    procedure Info(const AMsg: string);
    procedure Erro(const AMsg: string);
  end;

  TFileLogger = class(TInterfacedObject, ILogger)
  strict private
    FFileName: string;
    procedure WriteLine(const ALevel, AMsg: string);
  public
    constructor Create(const AFileName: string);
    procedure Info(const AMsg: string);
    procedure Erro(const AMsg: string);
  end;

implementation

uses
  System.Classes,
  System.SysUtils;

procedure TFileLogger.Erro(const AMsg: string);
begin
  WriteLine('ERRO', AMsg);
end;

constructor TFileLogger.Create(const AFileName: string);
begin
  inherited Create;
  FFileName := AFileName;
end;

procedure TFileLogger.Info(const AMsg: string);
begin
  WriteLine('INFO', AMsg);
end;

procedure TFileLogger.WriteLine(const ALevel, AMsg: string);
var
  LDirectory: string;
  LLines: TStringList;
begin
  LDirectory := ExtractFilePath(FFileName);
  if not LDirectory.IsEmpty then
    ForceDirectories(LDirectory);

  LLines := TStringList.Create;
  try
    if FileExists(FFileName) then
      LLines.LoadFromFile(FFileName, TEncoding.UTF8);
    LLines.Add(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' [' +
      ALevel + '] ' + AMsg);
    LLines.SaveToFile(FFileName, TEncoding.UTF8);
  finally
    LLines.Free;
  end;
end;

procedure TNullLogger.Erro(const AMsg: string);
begin
end;

procedure TNullLogger.Info(const AMsg: string);
begin
end;

end.
