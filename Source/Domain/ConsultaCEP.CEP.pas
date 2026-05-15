unit ConsultaCEP.CEP;

interface

type
  TCEP = record
  strict private
    FValor: string;
  public
    class function TryParse(const ATexto: string; out ACEP: TCEP): Boolean; static;
    property Valor: string read FValor;
  end;

implementation

uses
  System.SysUtils;

class function TCEP.TryParse(const ATexto: string; out ACEP: TCEP): Boolean;
var
  I: Integer;
  LTexto: string;
begin
  ACEP := Default(TCEP);
  LTexto := ATexto.Trim;
  Result := Length(LTexto) = 8;
  if Result then
    for I := 1 to 8 do
      if not CharInSet(LTexto[I], ['0'..'9']) then
        Exit(False);

  if Result then
    ACEP.FValor := LTexto;
end;

end.
