program Wuerfelspass;

{Programm: Kniffel-Clone
 Artikel:  Coding für Kids
 Autor:    T. Angielsky
 tangielskyblog.wordpress.com
}

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, haupt, meinwuerfel
  { you can add units after this };

{$R *.res}

begin
  Application.Title:='Programmieren lernen';
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(THauptForm, HauptForm);
  Application.Run;
end.

