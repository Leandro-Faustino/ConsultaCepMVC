unit ConsultaCEP.Interfaces;

interface

uses
  ConsultaCEP.DTO;

type
  IGatewayEndereco = interface
    ['{79C5E778-8994-43B2-8F57-A9D4F02B9411}']
    function Nome: string;
    function BuscarEndereco(const ACEP: string): TDadosEnderecoDTO;
  end;

  IRepositorioConsulta = interface
    ['{84594285-7E8B-47E3-953D-9695923CF896}']
    function Salvar(const AConsulta: TConsultaCEPRecord): Int64;
    function ListarTodos: TArray<TConsultaCEPRecord>;
  end;

  IConsultaCEPModel = interface
    ['{9809E6E1-C7FE-4523-8F88-29C953C9A9A1}']
    function ConsultarCEP(const ACEP: string): TDadosEnderecoDTO;
    function ObterHistorico: TArray<TConsultaCEPRecord>;
  end;

  IConsultaCEPView = interface
    ['{688CF710-F8E5-4E35-A258-124FB8B4E3A1}']
    procedure AtualizarEndereco(const ADTO: TDadosEnderecoDTO);
    procedure ExibirMensagem(const AMensagem: string);
    procedure ExibirHistorico(const ARegistros: TArray<TConsultaCEPRecord>);
    procedure SetCarregando(AValor: Boolean);
  end;

  IConsultaCEPController = interface
    ['{7CA71845-1D92-4CC4-B671-7A2921603524}']
    procedure ConsultarCEP(const ACEP: string);
    procedure SolicitarHistorico;
  end;

implementation

end.

