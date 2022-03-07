{**********************************************************}
{                                                          }
{  TLYAboutBox Component Version 02.12.2                   }
{  作者：刘鹰                                              }
{                                                          }
{                                                          }
{  新功能：1.增加访问网页的属性                            }
{          2.增加作者名                                    }
{          3.20161230增加微信公众号二维码                  }
{                                                          }
{  功能: 显示关于对话框                                    }
{                                                          }
{  约束条件：                                              }
{  1、因为uQRCode单元调用了PtImageRW.dll、PtQREncode.dll,  }
{     故应用程序目录必须存在这2个DLL                       }
{                                                          }
{  他是一个免费软件,如果你修改了他,希望我能有幸看到你的杰作}
{                                                          }
{  我的 Email: Liuying1129@163.com                         }
{                                                          }
{  版权所有,欲用于商业用途,请与我联系!!!                   }
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
    property WeChat:AnsiString read FWeChat write FWeChat;//微信公众号URL,用于生成二维码
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
                            //内存不足
    ERROR_FILE_NOT_FOUND: MessageBox(handle,'Error:File not Found','Error ExploreWeb',0);
                            //没有找到该文件
    ERROR_PATH_NOT_FOUND: MessageBox(handle,'Error:Directory not','Error ExploreWeb',0);
                            //路径不对
    ERROR_BAD_FORMAT : MessageBox(handle,'Fehler:Wrong format in EXE','Error ExploreWeb',0);
                            //文件格式不对
    Else MessageBox(handle,PChar('Error nr:'+IntToStr(Returnvalue)+' in ShellExecute'),'Error ExploreWeb',0) // 其 他 错 误
                            //还有其他错误处理，请参考帮助ShellExcute 的ReturnValues说明。
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
