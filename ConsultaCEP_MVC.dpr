program ConsultaCEP_MVC;

{$STRONGLINKTYPES ON}

uses
  Vcl.Forms,
  FireDAC.DApt,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  App.Registration in 'Source\Bootstrap\App.Registration.pas',
  ConsultaCEP.Controller in 'Source\Controller\ConsultaCEP.Controller.pas',
  ConsultaCEP.DTO in 'Source\Domain\ConsultaCEP.DTO.pas',
  ConsultaCEP.Interfaces in 'Source\Domain\ConsultaCEP.Interfaces.pas',
  ConsultaCEP.Gateway.BrasilAPI in 'Source\Integration\ConsultaCEP.Gateway.BrasilAPI.pas',
  ConsultaCEP.Gateway.ViaCEP in 'Source\Integration\ConsultaCEP.Gateway.ViaCEP.pas',
  ConsultaCEP.Model in 'Source\Model\ConsultaCEP.Model.pas',
  ConsultaCEP.Repository.FireDAC in 'Source\Persistence\ConsultaCEP.Repository.FireDAC.pas',
  ConsultaCEP.View.Main in 'Source\View\ConsultaCEP.View.Main.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  TAppRegistration.Configurar(FormMain);
  Application.Run;
end.
