unit helloworldplugin;

{$MODE Delphi}

interface

uses
  NppPlugin, SysUtils, LCLIntf, LCLType, LMessages, SciSupport, AboutForms, HelloWorldDockingForms,windows;

type
  THelloWorldPlugin = class(TNppPlugin)
  public
    constructor Create;
    procedure FuncHelloWorld;
    procedure FuncHelloWorldDocking;
    procedure FuncAbout;
    procedure DoNppnToolbarModification; override;
  end;

procedure _FuncHelloWorld; cdecl;
procedure _FuncHelloWorldDocking; cdecl;
procedure _FuncAbout; cdecl;

var
  Npp: THelloWorldPlugin;

implementation

{ THelloWorldPlugin }

constructor THelloWorldPlugin.Create;
var
  sk: TShortcutKey;
  i: Integer;
begin
  inherited;
  self.PluginName := 'Hello &World';
  i := 0;

  sk.IsCtrl := true; sk.IsAlt := true; sk.IsShift := false;
  sk.Key := #118; // CTRL ALT SHIFT F7
  self.AddFuncItem('Replace Hello World', _FuncHelloWorld, sk);

  self.AddFuncItem('Docking Test', _FuncHelloWorldDocking);

  self.AddFuncItem('-', _FuncHelloWorld);

  self.AddFuncItem('About', _FuncAbout);
end;

procedure _FuncHelloWorld; cdecl;
begin
  Npp.FuncHelloWorld;
end;
procedure _FuncAbout; cdecl;
begin
  Npp.FuncAbout;
end;
procedure _FuncHelloWorldDocking; cdecl;
begin
  Npp.FuncHelloWorldDocking;
end;

procedure THelloWorldPlugin.FuncHelloWorld;
var
  s: string;
begin
  s := 'Hello World';
  SendMessage(self.NppData.ScintillaMainHandle, SCI_REPLACESEL, 0, LPARAM(PChar(s)));
end;

procedure THelloWorldPlugin.FuncAbout;
var
  a: TAboutForm;
begin
  a := TAboutForm.Create(self);
  a.ShowModal;
  a.Free;
end;

procedure THelloWorldPlugin.FuncHelloWorldDocking;
begin
  if (not Assigned(HelloWorldDockingForm)) then HelloWorldDockingForm := THelloWorldDockingForm.Create(self, 1);
  HelloWorldDockingForm.Show;
end;

procedure THelloWorldPlugin.DoNppnToolbarModification;
var
  tb: TToolbarIcons;
begin
  tb.ToolbarIcon := 0;
  tb.ToolbarBmp := LoadImage(Hinstance, 'IDB_TB_TEST', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE or LR_LOADMAP3DCOLORS));
  SendMessage(self.NppData.NppHandle, NPPM_ADDTOOLBARICON, WPARAM(self.CmdIdFromDlgId(1)), LPARAM(@tb));
end;

initialization
  Npp := THelloWorldPlugin.Create;
end.
