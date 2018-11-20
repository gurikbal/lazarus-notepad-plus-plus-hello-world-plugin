{
    Delphi Foundation for creating plugins for Notepad++
    (Short: DFPN++)

    Copyright (C) 2009 Bastian Blumentritt

    This file is part of DFPN++.

    DFPN++ is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    DFPN++ is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with DFPN++.  If not, see <http://www.gnu.org/licenses/>.
}

unit nppp_scifuncs;

interface

uses
  Windows,
  nppp_types;

type
  TNPPSciFunctions = class(TObject)
  private
    FNPPHandle: HWND;
    FSci1Handle: HWND;
    FSci2Handle: HWND;
    FSciCurrentHandle: HWND;
    FNestedUpdateCalls: Cardinal;
  protected
  public
    constructor Create;
    procedure beginUpdate;
    procedure endUpdate;
    procedure setNPPHandle(pHandle: HWND);
    procedure setSci1Handle(pHandle: HWND);
    procedure setSci2Handle(pHandle: HWND);
    function getCurrentSciHandle: HWND;

    function getCurrentLine: Integer;
    function getSelectedText: nppString;
    function getSelectionEnd: Integer;
    function getSelectionStart: Integer;
    function getText: nppString;
    procedure goToLine(pLineNo: Integer);
    procedure replaceSelection(const pWith: nppString);
    procedure setSelectionEnd(pPos: Integer);
    procedure setSelectionStart(pPos: Integer);
  end;

implementation

uses
  nppp_consts;

{ TNPPBaseFunctions }

constructor TNPPSciFunctions.Create;
begin
  inherited;
  FNPPHandle := 0;
  FSci1Handle := 0;
  FSci2Handle := 0;
  FSciCurrentHandle := 0;
  FNestedUpdateCalls := 0;
end;

procedure TNPPSciFunctions.setNPPHandle(pHandle: HWND);
begin
  FNPPHandle := pHandle;
end;

procedure TNPPSciFunctions.setSci1Handle(pHandle: HWND);
begin
  FSci1Handle := pHandle;
end;

procedure TNPPSciFunctions.setSci2Handle(pHandle: HWND);
begin
  FSci2Handle := pHandle;
end;

function TNPPSciFunctions.getCurrentSciHandle: HWND;
var
  tP: PINT;
begin
  if FSciCurrentHandle > 0 then
    Result := FSciCurrentHandle
  else
  begin
    tP := new(PINT);

    SendMessage(FNPPHandle, NPPM_GETCURRENTSCINTILLA, 0, LPARAM(tP));
    if tP^ = 0 then
      Result := FSci1Handle
    else
      Result := FSci2Handle;

    Dispose(tP);
  end;
end;

procedure TNPPSciFunctions.beginUpdate;
begin
  Inc(FNestedUpdateCalls);
  if (FSciCurrentHandle = 0) then
    FSciCurrentHandle := getCurrentSciHandle;
end;

procedure TNPPSciFunctions.endUpdate;
begin
  if FNestedUpdateCalls <= 1 then
    FSciCurrentHandle := 0;
  if FNestedUpdateCalls > 0 then
    Dec(FNestedUpdateCalls);
end;

function TNPPSciFunctions.getCurrentLine: Integer;
var
  r: Integer;
begin
  beginUpdate;
  r := SendMessage(getCurrentSciHandle, SCI_GETCURRENTPOS, 0, 0);
  Result := SendMessage(getCurrentSciHandle, SCI_LINEFROMPOSITION, r, 0);
  endUpdate;
end;

function TNPPSciFunctions.getSelectedText: nppString;
var
  tR: Integer;
  tS: String;
begin
  beginUpdate;
  // determine selection length first
  // -> correctly returns selection length+1
  tR := SendMessage(getCurrentSciHandle, SCI_GETSELTEXT, 0, 0);
  SetLength(tS, tR);
  SendMessage(getCurrentSciHandle, SCI_GETSELTEXT, 0, LPARAM(PChar(tS)));

  Result := PChar(tS);

  endUpdate;
end;

function TNPPSciFunctions.getSelectionEnd: Integer;
begin
  Result := SendMessage(getCurrentSciHandle, SCI_GETSELECTIONEND, 0, 0);
end;

function TNPPSciFunctions.getSelectionStart: Integer;
begin
  Result := SendMessage(getCurrentSciHandle, SCI_GETSELECTIONSTART, 0, 0);
end;

/// This function returns the complete document content as string.
function TNPPSciFunctions.getText: nppString;
var
  tR: Integer;
  tS: String;
begin
  beginUpdate;
  tR := SendMessage(getCurrentSciHandle, SCI_GETTEXTLENGTH, 0, 0);
  Inc(tR);
  SetLength(tS, tR);
  SendMessage(getCurrentSciHandle, SCI_GETTEXT, tR, LPARAM(PChar(tS)));

  Result := PChar(tS);

  endUpdate;
end;

/// This removes any selection and sets the caret at the start of line
/// number /pLineNo/ and scrolls the view (if needed) to make it visible.
/// The anchor position is set the same as the current position. If /pLineNo/
/// is outside the lines in the document (first line is 0), the line set is
/// the first or last.
procedure TNPPSciFunctions.goToLine(pLineNo: Integer);
begin
  SendMessage(getCurrentSciHandle, SCI_GOTOLINE, pLineNo, 0);
end;

procedure TNPPSciFunctions.replaceSelection(const pWith: nppString);
begin
  SendMessage(getCurrentSciHandle, SCI_REPLACESEL, 0, LPARAM(PChar(String(pWith))));
end;

procedure TNPPSciFunctions.setSelectionEnd(pPos: Integer);
begin
  SendMessage(getCurrentSciHandle, SCI_SETSELECTIONEND, pPos, 0);
end;

procedure TNPPSciFunctions.setSelectionStart(pPos: Integer);
begin
  SendMessage(getCurrentSciHandle, SCI_SETSELECTIONSTART, pPos, 0);
end;

end.
