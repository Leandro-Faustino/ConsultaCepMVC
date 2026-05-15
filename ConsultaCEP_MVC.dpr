program ConsultaCEP_MVC;

{$STRONGLINKTYPES ON}

uses
  Vcl.Forms,
  FireDAC.DApt,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  App.Registration in 'Source\Bootstrap\App.Registration.pas',
  ConsultaCEP.Controller in 'Source\Controller\ConsultaCEP.Controller.pas',
  ConsultaCEP.CEP in 'Source\Domain\ConsultaCEP.CEP.pas',
  ConsultaCEP.DTO in 'Source\Domain\ConsultaCEP.DTO.pas',
  ConsultaCEP.Interfaces in 'Source\Domain\ConsultaCEP.Interfaces.pas',
  ConsultaCEP.Logger in 'Source\Infra\ConsultaCEP.Logger.pas',
  ConsultaCEP.Gateway.BrasilAPI in 'Source\Integration\ConsultaCEP.Gateway.BrasilAPI.pas',
  ConsultaCEP.Gateway.ViaCEP in 'Source\Integration\ConsultaCEP.Gateway.ViaCEP.pas',
  ConsultaCEP.Repository.FireDAC in 'Source\Persistence\ConsultaCEP.Repository.FireDAC.pas',
  ConsultaCEP.Service in 'Source\Service\ConsultaCEP.Service.pas',
  ConsultaCEP.View.Main in 'Source\View\ConsultaCEP.View.Main.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  TAppRegistration.Configurar(FormMain);
  Application.Run;
end.
