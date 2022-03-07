{**********************************************************}
{                                                          }
{  TLYAboutBox Component Version 02.12.2                   }
{  ���ߣ���ӥ                                              }
{                                                          }
{                                                          }
{  �¹��ܣ�1.���ӷ�����ҳ������                            }
{          2.����������                                    }
{          3.20161230����΢�Ź��ںŶ�ά��                  }
{                                                          }
{  ����: ��ʾ���ڶԻ���                                    }
{                                                          }
{  Լ��������                                              }
{  1����ΪuQRCode��Ԫ������PtImageRW.dll��PtQREncode.dll,  }
{     ��Ӧ�ó���Ŀ¼���������2��DLL                       }
{                                                          }
{  ����һ��������,������޸�����,ϣ���������ҿ�����Ľ���}
{                                                          }
{  �ҵ� Email: Liuying1129@163.com                         }
{                                                          }
{  ��Ȩ����,��������ҵ��;,��������ϵ!!!                   }
{                                                          }
{                                                          }
{**********************************************************}


unit LYAboutBox;

interface

uses
  forms, StdCtrls, Buttons, Graphics, Controls, ExtCtrls, Classes;

type
  TfrmLYAboutBox = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    Panel2: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    Comments: TLabel;
    WebPage: TLabel;
    Author: TLabel;
    ImageWeChat: TImage;
    ImageWeChatCS: TImage;
    Label1: TLabel;
    Label2: TLabel;
    procedure WebPageClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TLYAboutBox = class(TComponent)
  private
    { Private declarations }
    FProductName:AnsiString;
    FVersion:AnsiString;
    FCopyright:AnsiString;
    FComments:AnsiString;
    FAuthor:AnsiString;
    FWebPage:AnsiString;
    FWeChat:AnsiString;
    frmLYAboutBox:TfrmLYAboutBox;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor create(aowner:tcomponent);override;
    destructor destroy;override;
    function Execute:boolean;
  published
    { Published declarations }
    property ProcuctName:AnsiString read FProductName write FProductName;
    property Version:AnsiString read FVersion write FVersion;
    property Copyright:AnsiString read FCopyright write FCopyright;
    property Comments:AnsiString read FComments write FComments;
    property Author:AnsiString read FAuthor write FAuthor;
    property WebPage:AnsiString read FWebPage write FWebPage;
    property WeChat:AnsiString read FWeChat write FWeChat;//΢�Ź��ں�URL,�������ɶ�ά��
  end;

procedure Register;

implementation
uses
  shellapi,windows,SysUtils,UQRCodeLY;
  
{$R *.DFM}

procedure Register;
begin
  RegisterComponents('Eagle_Ly', [TLYAboutBox]);
end;

procedure ExploerWeb(handle:HWND ; page:PChar);
Var
  Returnvalue : integer;
begin 
  ReturnValue := ShellExecute(handle, 'open', page,nil, nil, SW_SHOWNORMAL);
  if ReturnValue <= 32 then
  case Returnvalue of
    0 : MessageBox(handle,'Error: Out of Memory','Error ExploreWeb',0);
                            //�ڴ治��
    ERROR_FILE_NOT_FOUND: MessageBox(handle,'Error:File not Found','Error ExploreWeb',0);
                            //û���ҵ����ļ�
    ERROR_PATH_NOT_FOUND: MessageBox(handle,'Error:Directory not','Error ExploreWeb',0);
                            //·������
    ERROR_BAD_FORMAT : MessageBox(handle,'Fehler:Wrong format in EXE','Error ExploreWeb',0);
                            //�ļ���ʽ����
    Else MessageBox(handle,PChar('Error nr:'+IntToStr(Returnvalue)+' in ShellExecute'),'Error ExploreWeb',0) // �� �� �� ��
                            //����������������ο�����ShellExcute ��ReturnValues˵����
  end //case
end;

constructor TLYAboutBox.create(aowner: tcomponent);
begin
  inherited;
  FProductName:='ProductName';
  FVersion:='Version';
  FCopyright:='Copyright';
  FComments:='Comments';
  FAuthor:='Author';
  FWebPage:='WebPage';
end;

destructor TLYAboutBox.destroy;
begin
  inherited;

end;

function TLYAboutBox.Execute: boolean;
begin
  frmLYAboutBox:=TfrmLYAboutBox.Create(application);
  try
    frmLYAboutBox.ProductName.Caption:=FProductName;
    frmLYAboutBox.Version.Caption:=FVersion;
    frmLYAboutBox.Copyright.Caption:=FCopyright;
    frmLYAboutBox.Comments.Caption:=FComments;
    frmLYAboutBox.Author.Caption:=FAuthor;
    frmLYAboutBox.WebPage.Caption:=FWebPage;
    frmLYAboutBox.ProgramIcon.Picture.Icon:=application.icon;

    CreateQRCode(FWeChat, 0, 0, 3,frmLYAboutBox.ImageWeChat);

    frmLYAboutBox.ShowModal;
  finally
    frmLYAboutBox.Free;
  end;
  result:=true;
end;

procedure TfrmLYAboutBox.WebPageClick(Sender: TObject);
begin
  ExploerWeb(handle,PChar(WebPage.caption));
end;

end.
