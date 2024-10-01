unit ChakraHttpClient;

{$mode delphi}

interface

  uses ChakraTypes;

  function GetJsValue: TJsValue;

implementation

  uses
    fpHttpClient, openssl, opensslsockets, Chakra, ChakraError, Classes;

  var Client: TFpHttpClient;

  function AddRequestHeader(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    AName, AValue: WideString;
  begin
    Result := Undefined;

    CheckParams('addRequestHeader', Args, ArgCount, [jsString, jsString], 2);

    AName := JsStringAsString(Args^); Inc(Args);
    AValue := JsStringAsString(Args^);

    Client.AddHeader(AName, AValue);
  end;

  function PostStringRequest(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    Response: TStringStream;
    AURL: WideString;
    ARequest: WideString;
  begin
    Result := Undefined;

    CheckParams('postStringRequest', Args, ArgCount, [jsString, jsString], 2);

    AURL := JsStringAsString(Args^); Inc(Args);
    ARequest := JsStringAsString(Args^);

    Client.RequestBody := TRawByteStringStream.Create(ARequest);
    Response := TStringStream.Create('');

    try

      Client.Post(AURL, Response);

      Result := StringAsJsString(Response.DataString);

    finally
      Client.RequestBody.Free;
      Response.Free;
    end;

  end;

  function GetResponseStatusCode(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    Result := IntAsJsNumber(Client.ResponseStatusCode);
  end;

  function DownloadFile(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    FileStream: TStream;
    AURL, AFileName: WideString;
  begin
    CheckParams('postResponse', Args, ArgCount, [jsString, jsString], 2);

    AURL := JsStringAsString(Args^); Inc(Args);
    AFileName := JsStringAsString(Args^);

    FileStream := TFileStream.Create(AFileName, fmCreate or fmOpenWrite);

    try

      Client.Get(AURL, FileStream);

    finally
      FileStream.Free;
    end;

  end;

  function GetResponse(Args: PJsValue; ArgCount: Word): TJsValue;
  var
    AURL: WideString;
  begin
    CheckParams('getResponse', Args, ArgCount, [jsString], 1);

    AURL := JsStringAsString(Args^);

    Result := StringAsJsString(Client.SimpleGet(AURL));
  end;

  function GetResponseHeadersString(Args: PJsValue; ArgCount: Word): TJsValue;
  begin
    Result := StringAsJsString(Client.ResponseHeaders.Text);
  end;

  function GetJsValue;
  begin
    Result := CreateObject;

    SetFunction(Result, 'addRequestHeader', AddRequestHeader);
    SetFunction(Result, 'downloadFile', DownloadFile);
    SetFunction(Result, 'getResponse', GetResponse);
    SetFunction(Result, 'postStringRequest', PostStringRequest);
    SetFunction(Result, 'getResponseStatusCode', GetResponseStatusCode);
    SetFunction(Result, 'getResponseHeadersString', GetResponseHeadersString);
  end;

initialization

  InitSSLInterface;
  Client := TFpHttpClient.Create(Nil);
  Client.AllowRedirect := True;

finalization

  Client.Free;

end.