unit ConsultaCEP.Tests.CEP;

interface

uses
  ConsultaCEP.CEP,
  DUnitX.TestFramework;

type
  [TestFixture]
  TCEPTests = class
  public
    [Test]
    procedure CEPCom8DigitosEValido;

    [Test]
    procedure CEPCurtoEInvalido;

    [Test]
    procedure CEPComLetrasEInvalido;

    [Test]
    procedure CEPVazioEInvalido;
  end;

implementation

procedure TCEPTests.CEPCom8DigitosEValido;
var
  LCEP: TCEP;
begin
  Assert.IsTrue(TCEP.TryParse('89201000', LCEP));
  Assert.AreEqual('89201000', LCEP.Valor);
end;

procedure TCEPTests.CEPComLetrasEInvalido;
var
  LCEP: TCEP;
begin
  Assert.IsFalse(TCEP.TryParse('89201A00', LCEP));
end;

procedure TCEPTests.CEPCurtoEInvalido;
var
  LCEP: TCEP;
begin
  Assert.IsFalse(TCEP.TryParse('8920', LCEP));
end;

procedure TCEPTests.CEPVazioEInvalido;
var
  LCEP: TCEP;
begin
  Assert.IsFalse(TCEP.TryParse('', LCEP));
end;

initialization
  TDUnitX.RegisterTestFixture(TCEPTests);

end.
