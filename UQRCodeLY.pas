unit UQRCodeLY;

interface

uses
  Windows, Graphics, ExtCtrls,SysUtils{Exception};
  
////////////////////////////////////////////////////////////////////////////////
//Image file reading/writing APIs and definitions.
////////////////////////////////////////////////////////////////////////////////
const
   PT_IMAGERW_FAIL                   =$00000000; //An error occured in an operation.
   PT_IMAGERW_SUCCESS                =$00000001; //An operation is successful.
   PT_IMAGERW_ALLOC_ERROR            =$00000100; //Error while allocating memory.
   PT_IMAGERW_FORMAT_UNSUPPORTED     =$00000101; //The format of image is unsupported.

type
   pPTIMAGESTRUCT=^PTIMAGESTRUCT  ;
   PTIMAGESTRUCT = record
        dwWidth  :     DWORD;     //The width of the image in pixels.
        dwHeight :     DWORD;     //The height of the image in pixels.
        pBits :        PByte ;    //Pointer to the image data.
        pPalette:      PByte;     //Pointer to the palette data (RGBQUAD)for 1,4,8 bit image.
        wBitsPerPixel: Smallint   //Number of bits per pixel.
   end;

  //使用动态加载
  //procedure PtInitImage(pImage: pPTIMAGESTRUCT);stdcall; far; external 'PtImageRW.dll' name 'PtInitImage';
  //procedure PtShowImage( pImage: pPTIMAGESTRUCT; hDc: HDC; StartX, StartY: Integer; Scale: Double);stdcall; far; external 'PtImageRW.dll' name 'PtShowImage';
  //Function PtLoadImage(fileName : AnsiString; pImage : pPTIMAGESTRUCT;  FrameIndex: DWORD) : Integer;stdcall; far; external 'PtImageRW.dll' name 'PtLoadImage';
  //Function PtSaveImage( fileName : AnsiString; pImage : pPTIMAGESTRUCT) : Integer;stdcall; far; external 'PtImageRW.dll' name 'PtSaveImage';
  //Function PtCreateImage( pImage : pPTIMAGESTRUCT; ImageSize: DWORD; PaletteSize:DWORD ) : Integer;stdcall; far; external 'PtImageRW.dll' name 'PtCreateImage';
  //procedure PtFreeImage(pImage: pPTIMAGESTRUCT);stdcall; far; external 'PtImageRW.dll' name 'PtFreeImage';

////////////////////////////////////////////////////////////////////////////////
//QR Code symbol writing APIs and definitions
////////////////////////////////////////////////////////////////////////////////
const
  PT_QRENCODE_FAIL             =$00000000; //An operation is Failed.
  PT_QRENCODE_SUCCESS          =$00000001; //An operation is successful.
  PT_QRENCODE_ALLOC_ERROR      =$00000200; //Error while allocating the memory.
  PT_QRENCODE_DATA_BIG         =$00000201; //Data to be encoded is too big.
  PT_QRENCODE_SIZE_SMALL       =$00000202; //The size of image to be pasted the symbol is too small.
  PT_QRENCODE_IMAGE_INVALID    =$00000203; //The image to be pasted is invalid.

  //QR Code ECC level constants
  PT_QR_ECCLEVEL_L	        =$0001; //Use ECC level L. (7% )
  PT_QR_ECCLEVEL_M          =$0000; //Use ECC level M. (15%)
  PT_QR_ECCLEVEL_Q          =$0003; //Use ECC level Q. (25%)
  PT_QR_ECCLEVEL_H	        =$0002; //Use ECC level H. (30%)

  //QR Code version constants
  PT_QR_VERSION_AUTO         =$0000; //Determine the version by the engine,then use the smallest version that can contain the data.

  //QR Code mask number constants
  PT_QR_MASKNUMBER_AUTO      =$0008; //Determine the mask number by the engine.

type
    pPTQRENCODESTRUCT=^PTQRENCODESTRUCT;
    PTQRENCODESTRUCT = record
        pData :              PAnsiChar ;    //Pointer to the data to be encoded.
        nDataLength :        Integer ;  //Length of the data in bytes.
        wVersion:            Smallint ;  //The version of the QR Code.
        wMaskNumber:         Smallint ;	//The mask number of the QR Code.
        wEccLevel  :         Smallint	; //Determines the ECC level for encoding a QR Code symbol.
        wModule  :           Smallint	; //The smallest element size in pixels.
        wGroupTotal :        Smallint	; //The number of symbols that belong to the group.
        wGroupIndex :        Smallint	; //The index of the symbol in the group
        wLeftSpace :         Smallint	; //The left   space of the symbol in pixels while generating Image.
        wRightSpace :        Smallint	; //The right  space of the symbol in pixels while generating Image.
        wTopSpace :          Smallint	; //The top    space of the symbol in pixels while generating Image.
        wBottomSpace :       Smallint	; //The bottom space of the symbol in pixels while generating Image.
   end;

  //使用动态加载
  //procedure PTQREncodeInit(pEncode: pPTQRENCODESTRUCT) ;stdcall; far; external 'PtQREncode.dll' name 'PtQREncodeInit';
  //function PtQREncode(pEncode: pPTQRENCODESTRUCT; pImage : pPTIMAGESTRUCT): Integer;stdcall; far; external 'PtQREncode.dll' name 'PtQREncode';
  //function PtQREncodeToImage(pEncode: pPTQRENCODESTRUCT; pImage: pPTIMAGESTRUCT; StartX: Integer; StartY: Integer): Integer;stdcall; far; external 'PtQREncode.dll' name 'PtQREncodeToImage';

  procedure CreateQRCode(ACode: AnsiString; AVersion, AEccLevel, AModule: SmallInt; AImage:TImage);

implementation

procedure CreateQRCode(ACode: AnsiString; AVersion, AEccLevel, AModule: SmallInt; AImage:TImage);
TYPE
  TDLL_PtInitImage=procedure(pImage: pPTIMAGESTRUCT);stdcall;
TYPE
  TDLL_PtQREncodeInit=procedure(pEncode: pPTQRENCODESTRUCT);stdcall;
TYPE
  TDLL_PtQREncode=function(pEncode: pPTQRENCODESTRUCT; pImage : pPTIMAGESTRUCT):Integer;stdcall;
TYPE
  TDLL_PtSaveImage=function(fileName : AnsiString; pImage : pPTIMAGESTRUCT):Integer;stdcall;
TYPE
  TDLL_PtFreeImage=procedure(pImage: pPTIMAGESTRUCT);stdcall;
var
  ret: integer;
  m_image: PTIMAGESTRUCT;
  m_encode: PTQRENCODESTRUCT;

  H_PtImageRW_LIB:THANDLE;
  H_PtQREncode_LIB:THANDLE;
  DLL_PtInitImage:TDLL_PtInitImage;
  DLL_PtQREncodeInit:TDLL_PtQREncodeInit;
  DLL_PtQREncode:TDLL_PtQREncode;
  DLL_PtSaveImage:TDLL_PtSaveImage;
  DLL_PtFreeImage:TDLL_PtFreeImage;
begin
  H_PtImageRW_LIB:=LOADLIBRARY('PtImageRW.dll');
  IF H_PtImageRW_LIB=0 THEN BEGIN raise Exception.Create('动态链接库PtImageRW.dll不存在!');EXIT; END;

  H_PtQREncode_LIB:=LOADLIBRARY('PtQREncode.dll');
  IF H_PtQREncode_LIB=0 THEN BEGIN FREELIBRARY(H_PtImageRW_LIB);raise Exception.Create('动态链接库PtQREncode.dll不存在!');EXIT; END;

  //执行PtInitImage(@m_image);
  DLL_PtInitImage:=TDLL_PtInitImage(GETPROCADDRESS(H_PtImageRW_LIB,'PtInitImage'));
  IF @DLL_PtInitImage=NIL THEN BEGIN FREELIBRARY(H_PtImageRW_LIB);FREELIBRARY(H_PtQREncode_LIB);raise Exception.Create('方法PtInitImage不存在!');EXIT; END;
  DLL_PtInitImage(@m_image);

  //执行PtQREncodeInit(@m_encode);
  DLL_PtQREncodeInit:=TDLL_PtQREncodeInit(GETPROCADDRESS(H_PtQREncode_LIB,'PtQREncodeInit'));
  IF @DLL_PtQREncodeInit=NIL THEN BEGIN FREELIBRARY(H_PtImageRW_LIB);FREELIBRARY(H_PtQREncode_LIB);raise Exception.Create('方法PtQREncodeInit不存在!');EXIT; END;
  DLL_PtQREncodeInit(@m_encode);

  m_encode.pData := PAnsiChar(ACode);
  m_encode.nDataLength := length(acode);
  m_encode.wVersion := AVersion;
  m_encode.wEccLevel := AEccLevel;
  m_encode.wModule := AModule;
  m_encode.wLeftSpace := 0;
  m_encode.wRightSpace := 0;
  m_encode.wTopSpace := 0;
  m_encode.wBottomSpace := 0;

  //执行ret := PtQREncode(@m_encode, @m_image);
  DLL_PtQREncode:=TDLL_PtQREncode(GETPROCADDRESS(H_PtQREncode_LIB,'PtQREncode'));
  IF @DLL_PtQREncode=NIL THEN BEGIN FREELIBRARY(H_PtImageRW_LIB);FREELIBRARY(H_PtQREncode_LIB);raise Exception.Create('函数PtQREncode不存在!');EXIT; END;
  ret := DLL_PtQREncode(@m_encode, @m_image);

  If ret = PT_QRENCODE_SUCCESS Then
  begin
    //执行ret := PtSaveImage( 'tmpWeChatQRCode.bmp', @m_image);
    DLL_PtSaveImage:=TDLL_PtSaveImage(GETPROCADDRESS(H_PtImageRW_LIB,'PtSaveImage'));
    IF @DLL_PtSaveImage=NIL THEN BEGIN FREELIBRARY(H_PtImageRW_LIB);FREELIBRARY(H_PtQREncode_LIB);raise Exception.Create('函数PtSaveImage不存在!');EXIT; END;
    ret := DLL_PtSaveImage('tmpWeChatQRCode.bmp', @m_image);

    If ret = PT_IMAGERW_SUCCESS Then
    begin
      AImage.Picture.LoadFromFile('tmpWeChatQRCode.bmp');
    end;
  end;//}

  {If ret = PT_QRENCODE_SUCCESS Then
  begin
    PtShowImage(@m_image, h, 0, 0, 0);
  end;//}

  //执行PtFreeImage(@m_image);
  DLL_PtFreeImage:=TDLL_PtFreeImage(GETPROCADDRESS(H_PtImageRW_LIB,'PtFreeImage'));
  IF @DLL_PtFreeImage=NIL THEN BEGIN FREELIBRARY(H_PtImageRW_LIB);FREELIBRARY(H_PtQREncode_LIB);raise Exception.Create('方法PtFreeImage不存在!');EXIT; END;
  DLL_PtFreeImage(@m_image);

  FREELIBRARY(H_PtImageRW_LIB);
  FREELIBRARY(H_PtQREncode_LIB);
end;

end.
