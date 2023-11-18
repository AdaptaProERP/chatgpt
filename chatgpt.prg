#include "FiveWin.ch"

#define EM_LIMITTEXT 197

Function Main()
   LOCAL oDlg, oGet1, cVar1 := "Hola OpenAI, cómo estás ? Me llamo Carlos, tú tienes nombre ?"
   LOCAL oGet2, cVar2 := Space(2048)
   LOCAL oFont1, oFont2, oBtn1, oSay1, oSay2
   LOCAL nChars := 2048
   TBtnBmp():lLegacyLookLeftRight := .T.
   
   cVar1 := "Puedes mostrarme el código de un programa escrito en lenguaje Harbour que en la function main tenga un Alert que diga 'Hola Mundo' ?"
   
   DEFINE FONT oFont1 NAME "Verdana" SIZE 0,-12 BOLD
   DEFINE FONT oFont2 NAME "Verdana" SIZE 0,-12
   DEFINE DIALOG oDlg FROM 0,0 TO 39,107 TRUEPIXEL TITLE "Taking with OPENAI API"
   
       @ 10,270 SAY "Talking with OPENAI API" OF oDlg FONT oFont1 SIZE 300,15PIXEL CENTER
       @ 28,20 SAY "You:" OF oDlg FONT oFont1 SIZE 50,15 PIXEL
   
       @ 28,680 SAY oSay1 VAR "Caracteres: 0 / "+cValToChar(nChars) OF oDlg PIXEL;
                        SIZE 120,15 UPDATE CENTER
   
       @ 45,20 GET oGet1 VAR cVar1 OF oDlg PIXEL SIZE 800,200 MEMO FONT oFont2;
               ON CHANGE(SB_LimitText(oGet1, oSay1, nChars))
            oGet1:bGotfocus := {||oGet1:SetSel(0,0)}
   
       @ 250,345 BTNBMP PROMPT "Submit" OF oDlg PIXEL ACTION Api_OpenAI(cVar1, oGet2) SIZE 150,45;
             FILE "openai24x24.png" LEFT NOBORDER 2007
   
       @ 300,20 SAY "OPENAI:" OF oDlg FONT oFont1 SIZE 70,15 PIXEL
   
       @ 317,20 GET oGet2 VAR cVar2 OF oDlg PIXEL SIZE 800,200 MEMO FONT oFont2
            oGet2:bGotfocus := {||oGet2:SetSel(0,0)}
   
       @ 535,620 BTNBMP PROMPT "Close" OF oDlg PIXEL ACTION oDlg:End() SIZE 150,45;
             FILE "exit24x24.png" LEFT NOBORDER 2007
   
       oDlg:bInit := {|| oGet1:SetFocus(),;
                          oGet1:LimitText(nChars),;
                          oSay1:VarPut("Caracteres: " + cValToChar(LEN( ALLTRIM( oGet1:cText ) )) + " / " + cValToChar(nChars)),;
                          oSay1:Refresh()}
   
   ACTIVATE DIALOG oDlg CENTERED ON PAINT oGet1:SetPos(0)
   
Return(NIL)

//------------------------------------------------------------//

Function Api_OpenAI(cPrompt, oGet2)
   LOCAL oSoap := CreateObject( "MSXML2.ServerXMLHTTP.6.0")
   LOCAL cUrl   := "https://api.openai.com/v1/engines/text-davinci-003/completions"
   LOCAL cToken := "sk-yours..."
   LOCAL cJSon, cRespApi, hResp := {=>}, cResp
   
   TEXT INTO cJson
        {
            "prompt": "cPrompt_empty",
            "temperature": 0,
            "max_tokens": 2048
        }
   ENDTEXT
   
   cPrompt := AllTrim(cPrompt)
   cJson := StrTran(cJson, "cPrompt_empty", cPrompt)
   
   oSoap:SetTimeouts(30000,30000,30000,30000)
   TRY
      oSoap:Open( "POST" , cUrl , .F. )
      oSoap:SetRequestHeader( "Content-Type", "application/json; charset=utf-8" )
      oSoap:setRequestHeader("Authorization", "Bearer "+cToken )
      oSoap:Send(cJson)
   
      cRespApi := Alltrim(oSoap:responseText)
      hb_jsondecode(cRespApi,@hResp)
   
      cResp := hResp["choices"][1]["text"]
      cResp := StrTran(cResp, Chr(10), Chr(13)+Chr(10))
      oGet2:VarPut( AllTrim(cResp) )
      oGet2:Refresh()
   
     // MsgInfo( oSoap:Status )
   
   CATCH
      msginfo("Mensaje en el CATCH"+CRLF+CRLF+ "No hay conexión con el servidor de Rindegastos."+CRLF+ "  Por favor vuelva a intentarlo.","Intente Nuevamente")
   
   END
   
Return(oSoap)
//------------------------------------------------------------//


FUNCTION SB_LimitText( oGet, oSay, nLimObserv )
   ///////////////////////////////////////////////////////////////////////////
   // Autor..........: Peguei no Forum FiveWin Brasil                       //
   // Modificaçoes...: Ale SB - Soft Camus                                  //
   // Descricao......: Restringe o Tamanho de um Texto.                     //
   // Parametros ==>                                                        //
   //  - oGet  : oBjeto Get.                                                //
   //  - nSize : Tamanho que deve ter o Texto.                              //
   // Dependencias ==>                                                      //
   // Retorno ==> nil                                                       //
   ///////////////////////////////////////////////////////////////////////////
   LOCAL nTam, nSize
   DEFAULT nSize := nLimObserv  // 19  // 99 // maximo e 100 caracteres
   nTam := LEN( ALLTRIM( oGet:cText ) )
   IF nTam > nSize
      Msginfo( "Lo siento, no puedo continuar, el tamaño máximo " + ;
               "ha excedido el límite permitido.", "Atención por favor." )
      oGet:cText := Substr(oGet:cText, 1, nTam-1)
      RETURN( .F. )
   ENDIF
   oSay:VarPut("Caracteres: " + cValToChar(nTam) + " / " + cValToChar(nLimObserv))
     oSay:Refresh()
RETURN( .T. )
//------------------------------------------------------------//
 