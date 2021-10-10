{
 Este software foi escrito para auxiliar na importação das notas fiscais de
 serviço eletrônica (NFSe), através do XML gerado pelo sistema da Sonner
 (www.sonner.com.br) usado pela Prefeitura Municipal da cidade de Lavras/MG, no
 endereço eletrônico: nfe-cidades.com.br (antigo govdigital.com.br).

 O sistema importa o arquivo XML gerado e cria um dataset com as notas fiscais
 presentes no mesmo. O XML pode conter uma ou mais notas fiscais.

 Declaro que NÃO TEMOS VINCULO ALGUM com a empresa Sonner.

 Este software e todos os seus fontes estão licenciados pelos termos da MIT.
 Um arquivo chamado LICENSING está presente na raíz do diretório, com os termos
 da licença.

 ###############################################################################
 Autor: DNatividade
 Data: 2021-10-03
 ###############################################################################
}
unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ActnList, DBGrids, ExtCtrls;

type

  { TfrmNFSeLavras }

  TfrmNFSeLavras = class(TForm)
    bfItem: TBufDataset;
    btXML: TBitBtn;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    dsItem: TDataSource;
    DefineBufFields: TAction;
    ActionList1: TActionList;
    bfNFe: TBufDataset;
    dsNFe: TDataSource;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    procedure btXMLClick(Sender: TObject);
    procedure DefineBufFieldsExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmNFSeLavras: TfrmNFSeLavras;

implementation

//uses XMLRead, XMLWrite, DOM;
uses   laz2_xmlread, laz2_dom;

{$R *.lfm}

{ TfrmNFSeLavras }


procedure TfrmNFSeLavras.btXMLClick(Sender: TObject);
var
  doc: TXMLDocument;
  nEmissao, nNFE,
  nNItens, nNItens2, nIItens: TDOMNode;
  filename, line: string;
  found: integer;
  arq: TextFile;

  ID_NFE, ID_ITEM: integer;

begin
  if OpenDialog1.Execute then
  begin
    try
      found:= 0;
      //Read XML file from disk
      filename:= OpenDialog1.FileName;
      AssignFile(arq, filename);

      //checa se é um arquivo XML valido (procura por <GovGidital>)
      Reset(arq);
      While not Eof(arq) do
      begin
        readln(arq, line);
        if Pos('<GovDigital>', line) <> 0 then
        begin
          found:= 1;
          break;
        end;
      end;

      if found = 0 then
      begin
        ShowMessage('Arquivo XML inválido!');
        Abort; //aborta o carregamento do arquivo caso não seja um XML válido
      end;
      finally
        CloseFile(arq);
      end;

    try
      //reabre o arquivo
      Reset(arq);
      ReadXMLFile(doc, arq);

      //configura o separador decimal para as conversoes de STRING para FLOAT
      DecimalSeparator:='.';
      //inicializa o ID das tabelas
      ID_NFE:=  0;
      ID_ITEM:= 0;

      nEmissao:= doc.DocumentElement.FindNode('emissao');
      while nEmissao <> nil do
      begin
        nNFE:= nEmissao.FirstChild;
        while nNFE <> nil do
        begin
          ID_NFE:= ID_NFE + 1;
          bfNFe.Append;
          bfNFe.FieldByName('idNfe').AsInteger:= ID_NFE;
          nNItens:= nNFE.FirstChild;
          while nNItens <> nil do
          begin
            if nNItens.NodeName = 'prestacao' then
              bfNFe.FieldByName('prestacao').AsString:= nNItens.TextContent
            else if nNItens.NodeName = 'exigibilidade' then
              bfNFe.FieldByName('exigibilidade').AsInteger:= StrToInt(nNItens.TextContent)
            else if nNItens.NodeName = 'retido' then
              bfNFe.FieldByName('retido').AsInteger:= StrToInt(nNItens.TextContent)
            else if nNItens.NodeName = 'municipioIncidencia' then
              bfNFe.FieldByName('municipioIncidencia').AsString:= nNItens.TextContent
            else if nNItens.NodeName = 'atividade' then
              bfNFe.FieldByName('atividade').AsString:= nNItens.TextContent
            else if nNItens.NodeName = 'aliquota' then
              bfNFe.FieldByName('aliquota').AsFloat:= StrToFloat(nNItens.TextContent)

            //PRESTADOR --  PRESTADOR --  PRESTADOR --  PRESTADOR --  PRESTADOR
            else if nNItens.NodeName = 'prestador' then
            begin
              nNItens2:= nNItens.FirstChild;
              while nNItens2 <> nil do
              begin
                //bfNFe.Edit;
                if nNItens2.NodeName = 'documento' then
                  bfNFe.FieldByName('documentoP').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'nome' then
                  bfNFe.FieldByName('nomeP').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'cep' then
                  bfNFe.FieldByName('cepP').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'logradouro' then
                  bfNFe.FieldByName('logradouroP').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'numero' then
                  bfNFe.FieldByName('numeroP').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'bairro' then
                  bfNFe.FieldByName('bairroP').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'estado' then
                  bfNFe.FieldByName('estadoP').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'municipio' then
                  bfNFe.FieldByName('municipioP').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'pais' then
                  bfNFe.FieldByName('paisP').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'telefone' then
                  bfNFe.FieldByName('telefoneP').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'email' then
                  bfNFe.FieldByName('emailP').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'inscEst' then
                  bfNFe.FieldByName('inscEstP').AsString:= nNItens2.TextContent;

                nNItens2:= nNItens2.NextSibling;
              end;
            end

            //REGIME
            else if nNItens.NodeName = 'regime' then
              bfNFe.FieldByName('regime').AsString:= nNItens.TextContent

            //TOMADOR -- TOMADOR -- TOMADOR -- TOMADOR -- TOMADOR
            else if nNItens.NodeName = 'tomador' then
            begin
              nNItens2:= nNItens.FirstChild;
              while nNItens2 <> nil do
              begin
                //bfNFe.Edit;
                if nNItens2.NodeName = 'documento' then
                  bfNFe.FieldByName('documentoT').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'nome' then
                  bfNFe.FieldByName('nomeT').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'cep' then
                  bfNFe.FieldByName('cepT').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'logradouro' then
                  bfNFe.FieldByName('logradouroT').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'numero' then
                  bfNFe.FieldByName('numeroT').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'bairro' then
                  bfNFe.FieldByName('bairroT').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'estado' then
                  bfNFe.FieldByName('estadoT').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'municipio' then
                  bfNFe.FieldByName('municipioT').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'pais' then
                  bfNFe.FieldByName('paisT').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'telefone' then
                  bfNFe.FieldByName('telefoneT').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'email' then
                  bfNFe.FieldByName('emailT').AsString:= nNItens2.TextContent
                else if nNItens2.NodeName = 'inscEst' then
                  bfNFe.FieldByName('inscEstT').AsString:= nNItens2.TextContent;

                nNItens2:= nNItens2.NextSibling;
              end;
            end

            //ITENS -- ITENS -- ITENS -- ITENS -- ITENS
            else if nNItens.NodeName = 'itens' then
            begin
              nNItens2:= nNItens.FirstChild;
              while nNItens2 <> nil do
              begin
                ID_ITEM:= ID_ITEM + 1;
                bfItem.Append;
                if nNItens2.NodeName = 'item' then
                begin
                  nIItens:= nNItens2.FirstChild;
                  while nIItens <> nil do
                  begin
                    bfItem.Edit;

                    bfItem.FieldByName('idNfe').AsInteger:= ID_NFE;
                    bfItem.FieldByName('idItem').AsInteger:= ID_ITEM;

                    if nIItens.NodeName = 'atividade' then
                      bfItem.FieldByName('atividade').AsString:= nIItens.TextContent
                    else if nIItens.NodeName = 'descricao' then
                      bfItem.FieldByName('descricao').AsString:= nIItens.TextContent
                    else if nIItens.NodeName = 'aliquota' then
                      bfItem.FieldByName('aliquota').AsFloat:= StrToFloat(nIItens.TextContent)
                    else if nIItens.NodeName = 'valorUn' then
                      bfItem.FieldByName('valorUn').AsFloat:= StrToFloat(nIItens.TextContent)
                    else if nIItens.NodeName = 'quantidade' then
                      bfItem.FieldByName('quantidade').AsFloat:= StrToFloat(nIItens.TextContent)
                    else if nIItens.NodeName = 'valor' then
                      bfItem.FieldByName('valor').AsFloat:= StrToFloat(nIItens.TextContent);

                    bfItem.Post;
                    nIItens:= nIItens.NextSibling;
                  end;
                end;
                nNItens2:= nNItens2.NextSibling;
              end;
            end


            //terceira parte
            else if nNItens.NodeName = 'obs' then
              bfNFe.FieldByName('obs').AsString:= nNItens.TextContent
            else if nNItens.NodeName = 'deducoes' then
              bfNFe.FieldByName('deducoes').AsString:= nNItens.TextContent
            else if nNItens.NodeName = 'senha' then
              bfNFe.FieldByName('senha').AsString:= nNItens.TextContent
            else if nNItens.NodeName = 'serie' then
              bfNFe.FieldByName('serie').AsString:= nNItens.TextContent
            else if nNItens.NodeName = 'valorTotal' then
              bfNFe.FieldByName('valorTotal').AsFloat:= StrToFloat(nNItens.TextContent)
            else if nNItens.NodeName = 'valorBase' then
              bfNFe.FieldByName('valorBase').AsFloat:= StrToFloat(nNItens.TextContent)
            else if nNItens.NodeName = 'valorImposto' then
              bfNFe.FieldByName('valorImposto').AsFloat:= StrToFloat(nNItens.TextContent)
            else if nNItens.NodeName = 'valorLiquido' then
              bfNFe.FieldByName('valorLiquido').AsFloat:= StrToFloat(nNItens.TextContent);

            nNItens:= nNItens.NextSibling;
          end;

          nNFE:= nNFE.NextSibling;
          bfNFe.Post;
        end;
        nEmissao:= nEmissao.NextSibling;
      end;
    finally
      CloseFile(arq);
      doc.Free;
      DecimalSeparator:=',';
    end;
    btXML.Enabled:= false;
  end;
end;


procedure TfrmNFSeLavras.DefineBufFieldsExecute(Sender: TObject);
begin
  Try
    //dados da nota fiscal
    bfNFe.FieldDefs.Add('idNfe', ftInteger); //ID da nota
    //
    bfNFe.FieldDefs.Add('prestacao', ftString, 10); //data da emissao da nota no formato YYYY-MM-DD. ex.: 2021-12-31
    bfNFe.FieldDefs.Add('exigibilidade', ftInteger);
    bfNFe.FieldDefs.Add('retido', ftInteger); //imposto retido na fonte: 1=NAO; 2=SIM
    bfNFe.FieldDefs.Add('municipioIncidencia', ftString);
    bfNFe.FieldDefs.Add('atividade', ftString, 5); //codigo da atividade. ex.: 1.07
    bfNFe.FieldDefs.Add('aliquota', ftFloat); //aliquota de imposto
    //
    bfNFe.FieldDefs.Add('regime', ftString, 60); //ex.: Simples
    //
    bfNFe.FieldDefs.Add('obs', ftString, 200); //observações
    bfNFe.FieldDefs.Add('deducoes', ftString, 60); //? (não utilizei ainda)
    bfNFe.FieldDefs.Add('senha', ftString, 20); //chave da nota (19 caracteres) ex.: 00AA.AA00.0000.AAAA
    bfNFe.FieldDefs.Add('numero', ftString, 20); //numero da nota
    bfNFe.FieldDefs.Add('serie', ftString, 60); //serie da nota. ex.: ELETRONICA (acho que atualmente so existe essa)
    bfNFe.FieldDefs.Add('valorTotal', ftFloat); //valor total bruto da nota
    bfNFe.FieldDefs.Add('valorBase', ftFloat); //valor para a base de calculo de impostos (normalmente igual ao valorTotal)
    bfNFe.FieldDefs.Add('valorImposto', ftFloat); //valor do imposto pago pela nota
    bfNFe.FieldDefs.Add('valorLiquido', ftFloat); //valor total a receber. caso "retido"=2, será escontado o "valorImposto" neste valor
    //dados do prestador de serviços
    bfNFe.FieldDefs.Add('documentoP', ftString, 14); //CNPJ/CPF (somente numeros)
    bfNFe.FieldDefs.Add('nomeP', ftString, 60);
    bfNFe.FieldDefs.Add('cepP', ftString, 15); //normalmente de 8 a 10 caracteres (mas já vi cadastros errados em que o sistema aceitou)
    bfNFe.FieldDefs.Add('logradouroP', ftString, 60);
    bfNFe.FieldDefs.Add('numeroP', ftString, 10);
    bfNFe.FieldDefs.Add('complementoP', ftString, 60);
    bfNFe.FieldDefs.Add('bairroP', ftString, 60);
    bfNFe.FieldDefs.Add('estadoP', ftString, 2);
    bfNFe.FieldDefs.Add('municipioP', ftString, 60);
    bfNFe.FieldDefs.Add('paisP', ftString, 60);
    bfNFe.FieldDefs.Add('telefoneP', ftString, 30);
    bfNFe.FieldDefs.Add('emailP', ftString, 60);
    bfNFe.FieldDefs.Add('inscEstP', ftString, 30); //inscrição estadual
    //dados dos clientes (ou tomador do serviço)
    bfNFe.FieldDefs.Add('documentoT', ftString, 14); //CNPJ/CPF (somente numeros)
    bfNFe.FieldDefs.Add('nomeT', ftString, 60);
    bfNFe.FieldDefs.Add('cepT', ftString, 15); //normalmente de 8 a 10 caracteres (mas já vi cadastros errados em que o sistema aceitou)
    bfNFe.FieldDefs.Add('logradouroT', ftString, 60);
    bfNFe.FieldDefs.Add('numeroT', ftString, 10);
    bfNFe.FieldDefs.Add('complementoT', ftString, 60);
    bfNFe.FieldDefs.Add('bairroT', ftString, 60);
    bfNFe.FieldDefs.Add('estadoT', ftString, 2);
    bfNFe.FieldDefs.Add('municipioT', ftString, 60);
    bfNFe.FieldDefs.Add('paisT', ftString, 60);
    bfNFe.FieldDefs.Add('telefoneT', ftString, 30);
    bfNFe.FieldDefs.Add('emailT', ftString, 60);
    bfNFe.FieldDefs.Add('inscEstT', ftString, 30); //inscrição estadual
    bfNFe.CreateDataset;


    //itens de serviços
    bfItem.FieldDefs.Add('idItem', ftInteger); //ID do item
    bfItem.FieldDefs.Add('idNfe', ftInteger); //refere-se ao ID da nota
    //
    bfItem.FieldDefs.Add('atividade', ftString, 5); //codigo da atividade. ex.: 1.07
    bfItem.FieldDefs.Add('descricao', ftString, 100); //descricao do serviço
    bfItem.FieldDefs.Add('aliquota', ftFloat); //aliquota de imposto
    bfItem.FieldDefs.Add('valorUn', ftFloat); //valor unitario do serviço
    bfItem.FieldDefs.Add('quantidade', ftFloat); //quantidade do serviço prestado
    bfItem.FieldDefs.Add('valor', ftFloat); //valor total do serviço
    bfItem.CreateDataset;
    //
    //
    bfNFe.Open;
    bfItem.Open;
  finally

  end;

end;

procedure TfrmNFSeLavras.FormCreate(Sender: TObject);
begin
  DefineBufFields.Execute;
end;

end.

