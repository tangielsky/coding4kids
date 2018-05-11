unit haupt;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, Grids, Buttons, StdCtrls, meinwuerfel;

const
  //So heißt dein Spiel
  Spielname = 'Würfelspaß';

type
  { THauptForm }
  THauptForm = class(TForm)
    ImageBecher: TImage;
    Label1: TLabel;
    ListView1: TListView;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel4: TPanel;
    PanelMeldung: TPanel;
    PanelRunde: TPanel;
    PanelSpielfeld: TPanel;
    PanelWurf: TPanel;
    Shape1: TShape;
    SpeedButtonNeuesSpiel: TSpeedButton;
    SpeedButtonWuerfeln: TSpeedButton;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure SpeedButtonNeuesSpielClick(Sender: TObject);
    procedure SpeedButtonWuerfelnMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SpeedButtonWuerfelnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
  private
    Runde : integer;
    Wurf : integer;
    BecherX, BecherSchritt : integer;
    function AnzahlZahl(Zahl: integer): integer;
    procedure Meldung(anzeigetext: string);
    procedure PunkteLoeschen;
    procedure Spielende;
    procedure SpielInfosAnzeigen;
    function SummeAugen: integer;
    procedure UpdateListview(Nr: integer; Wert : string);
    procedure VorschlaegeLoeschen;
    procedure WuerfelAnzeigen(status: boolean;NurWuefelfeld: boolean);
    procedure Wuerfeln(NurWuefelfeld: boolean);
    procedure WurfBerechnen;
    procedure WurfEintragen;
    { private declarations }
  public
    { public declarations }
  end;

var
  HauptForm: THauptForm;


implementation

{$R *.lfm}


procedure Delay(const Milliseconds: DWord);
var
  FirstTickCount: DWord;
begin
  FirstTickCount := GetTickCount;
  while ((GetTickCount - FirstTickCount) < Milliseconds) do
  begin
    Application.ProcessMessages;
    Sleep(0);
  end;
end;


//Funktion zur Umwandlung von String in Integer
//Das hat den Vorteil, dass keine Exception erzeugt wird,
//wenn die Umwandlung nicht funktioniert.
//Passiert das, wird 0 zurückgegeben
function StrInt(s : string) : integer;
var i,j : integer;
begin
  val(s,i,j);
  result:=i;
end;


//Eine Meldung im Panel anzeigen
procedure THauptForm.Meldung(anzeigetext : string);
begin
  PanelMeldung.Caption:=anzeigetext;
end;

//Infos zum Spiel anzeigen
procedure THauptForm.SpielInfosAnzeigen;
begin
  PanelWurf.Caption:='Wurf: '+IntToStr(Wurf);
  PanelRunde.Caption:='Runde: '+IntToStr(Runde);
end;


//Alle Würfel werden EIN- oder AUSgeblendet
procedure THauptForm.WuerfelAnzeigen(status : boolean; NurWuefelfeld: boolean);
var i : integer;
begin
  for i:=1 to 5 do
    if (NurWuefelfeld=true) and (wuerfel[i].IstImWuerfelfeld=true) then
      wuerfel[i].Visible:=status
    else if NurWuefelfeld=false then wuerfel[i].Visible:=status;
  SpeedButtonWuerfeln.Enabled:=true;
end;

procedure THauptForm.UpdateListview(Nr : integer; Wert : string);
var ListItem : TListItem;
begin
  //Punkte eintragen, wenn es den Wurf noch nicht gibt
  ListItem:=ListView1.Items[Nr];
  if ListItem.SubItems[0]='' then ListItem.SubItems[1]:=Wert
  else ListItem.SubItems[1]:='';
end;

procedure THauptForm.Wuerfeln(NurWuefelfeld : boolean);
var i : integer;
begin
  //Würfel im Würfelfeld bekommen eine neue Zufallszahl
  for i:=1 to 5 do
    if NurWuefelfeld=true then
      begin
        if wuerfel[i].IstImWuerfelfeld=NurWuefelfeld then wuerfel[i].Wuerfeln;
      end else wuerfel[i].Wuerfeln;
  WurfBerechnen;
end;


//Funktionen zum Berechnen des aktuellen Wurfs

//Anzahl der Würfel mit "Zahl" suchen und zählen
function THauptForm.AnzahlZahl(Zahl : integer): integer;
var i,j : integer;
begin
  //Rückgabewert der Funktion auf 0 setzten
  result:=0;
  j:=0;
  for i:=1 to 5 do
    if wuerfel[i].Zahl=Zahl then j:=j+1;

  //Rückgabewert auf den Wert von j setzen
  result:=j;
end;

//Summe aller Augen berechnen
function THauptForm.SummeAugen: integer;
var i,j : integer;
begin
  result:=0;
  j:=0;
  for i:=1 to 5 do
    j:=j+wuerfel[i].Zahl;
  result:=j;
end;


//Funktion zum Berechnen des Wurfs
procedure THauptForm.WurfBerechnen;
var
  i,t1,t2,dreierpasch : integer;
  sl : TStringList;
begin
  //1er bis 6er
  for i:=1 to 6 do
    UpdateListview(i-1,IntToStr(AnzahlZahl(i)*i));

  //alle anderen Felder auf 0 setzten
  for i:=10 to 16 do
    UpdateListview(i,IntToStr(0));


  //3er Pasch
  dreierpasch:=0;
  for i:=1 to 6 do
    if AnzahlZahl(i)>=3 then
      begin
        UpdateListview(10,IntToStr(SummeAugen));
        dreierpasch:=i;
      end;

  //4er Pasch
  for i:=1 to 6 do
    if AnzahlZahl(i)>=4 then UpdateListview(11,IntToStr(SummeAugen));

  //Full House
  if dreierpasch>0 then
    for i:=1 to 6 do
      if (AnzahlZahl(i)=2) and (dreierpasch<>i) then UpdateListview(12,IntToStr(25));

  //Kleine Straße
  //Hier wird ein Objekt einer Klasse TStringlist erzeugt.
  //Diese brauchen wir, um die Würfel einfach zu sortieren
  sl:=TStringList.Create;
  for i:=1 to 5 do
    sl.Add(IntToStr(wuerfel[i].Zahl));
  sl.Sort;
  //Prüfen, ob aktueller Würfel gleich dem vorherigen ist
  //wenn ja dann den aktuellen um 90 erhöhen
  for i:=1 to 4 do
    if sl[i]=sl[i-1] then sl[i]:=IntToStr(i+90);
  sl.Sort;

  //Abfragen, ob es eine Reihe gibt
  if (StrInt(sl[0])=StrInt(sl[1])-1)
    and (StrInt(sl[1])=StrInt(sl[2])-1)
    and (StrInt(sl[2])=StrInt(sl[3])-1)
    then UpdateListview(13,IntToStr(30));
  if (StrInt(sl[1])=StrInt(sl[2])-1)
    and (StrInt(sl[2])=StrInt(sl[3])-1)
    and (StrInt(sl[3])=StrInt(sl[4])-1)
    then UpdateListview(13,IntToStr(30));


  //Große Straße
  if (StrInt(sl[0])=StrInt(sl[1])-1)
    and (StrInt(sl[1])=StrInt(sl[2])-1)
    and (StrInt(sl[2])=StrInt(sl[3])-1)
    and (StrInt(sl[3])=StrInt(sl[4])-1) then UpdateListview(14,IntToStr(40));

  //Stringlist wieder zerstören
  sl.Free;

  //5 gleiche
  UpdateListview(15,IntToStr(0));
  for i:=1 to 6 do
    if AnzahlZahl(i)=5 then UpdateListview(15,IntToStr(50));

  //Chance
  UpdateListview(16,IntToStr(SummeAugen));


  //Punkte berechnen für Teil 1
  t1:=0;
  for i:=0 to 5 do
    t1:=t1+StrInt(ListView1.Items[i].SubItems[0]);
  ListView1.Items[6].SubItems[0]:=IntToStr(t1);

  //Gibt es einen Bonus?
  if t1>=63 then
    begin
      ListView1.Items[7].SubItems[0]:='35';
      t1:=t1+35;
    end else ListView1.Items[7].SubItems[0]:='0';
  ListView1.Items[8].SubItems[0]:=IntToStr(t1);

  //Punkte berechnen für Teil 2
  t2:=0;
  for i:=0 to 6 do
    t2:=t2+StrInt(ListView1.Items[10+i].SubItems[0]);
  ListView1.Items[17].SubItems[0]:=IntToStr(t2);
  ListView1.Items[18].SubItems[0]:=IntToStr(t1+t2);

  ListView1.Update;

  //Kein Element der ListView soll markiert sein
  ListView1.Selected:=nil;

  Meldung('Schiebe die Würfel vom Spielfeld, die Du behalten möchtest.');
end;

procedure THauptForm.PunkteLoeschen;
var i : integer;
begin
  //Punkte löschen
  for i:=0 to ListView1.Items.Count-1 do
    begin
      ListView1.Items[i].SubItems.Clear;
      ListView1.Items[i].SubItems.Add('');
      ListView1.Items[i].SubItems.Add('');
    end;
end;

procedure THauptForm.VorschlaegeLoeschen;
var i : integer;
begin
  //Alle Zeilen der Vorschlag-Spalte löschen
  for i:=0 to ListView1.Items.Count-1 do
    ListView1.Items[i].SubItems[1]:='';
end;

procedure THauptForm.Spielende;
var i : integer;
begin
  //Button "Würfeln" deaktivieren
   SpeedButtonWuerfeln.Enabled:=false;

   //alle Würfel verstecken
   for i:=1 to 5 do
     wuerfel[i].Hide;
end;


procedure THauptForm.WurfEintragen;
begin

  //Prüfungen, ob Punkte eingetragen werden dürfen
  if ListView1.Selected=nil then
    begin
      Meldung('Vorher in der Tabelle eine Zeile auswählen.');
      exit;
    end;

  if ListView1.Selected.SubItems[1]='' then
    begin
      Meldung('Das Feld wurde bereits ausgewählt!');
      exit;
    end;

  //Berechnete Punkte übernehmen aus der Spalte "Aktueller Wurf"
  ListView1.Selected.SubItems[0]:=ListView1.Selected.SubItems[1];

  //Dann alle Vorschläge löschen
  VorschlaegeLoeschen;

  //Nächste Runde oder Spielende
  if Runde=13 then
    begin
      //Spielende
      WurfBerechnen;
      Meldung('Du hast '+ListView1.Items[18].SubItems[0]+' Punkte erreicht.');
      Spielende;
    end
  else
    begin
      //Neue Runde
      Runde:=Runde+1;
      Wurf:=1;
      SpeedButtonWuerfeln.Enabled:=true;

      //Neu würfeln, alle Würfel
      //aber mit Animation
      WuerfelAnzeigen(false,false); //alle Würfel ausblenden
      ImageBecher.Visible:=true;    //Becher einblenden
      Timer1.Enabled:=true;         //Timer für Becher-Bewegung ein
      Delay(1000);                  //1 Sekunden Becher "schütteln"
      Timer1.Enabled:=false;        //Timer wieder aus
      ImageBecher.Visible:=false;   //Becher ausblenden
      Wuerfeln(false);              //Neue Zufallswerte für alle Würfel
      WuerfelAnzeigen(true,false);  //alle Würfel wieder anzeigen

      SpielInfosAnzeigen;
    end;
end;

procedure THauptForm.SpeedButtonNeuesSpielClick(Sender: TObject);
var i : integer;
begin
  //Startwerte setzen
  Runde:=1;
  Wurf:=1;
  PunkteLoeschen;

  //Los gehts
  Wuerfeln(false);             //Neue Zufallswerte für alle Würfel
  WuerfelAnzeigen(true,false); //alle Würfel anzeigen
  SpielInfosAnzeigen;
  WurfBerechnen;
end;

procedure THauptForm.SpeedButtonWuerfelnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Meldung('Drücke solange auf "Würfeln" wie du würfeln willst.');
  WuerfelAnzeigen(false,true);
  ImageBecher.Visible:=true;
  Timer1.Enabled:=true;
end;

procedure THauptForm.SpeedButtonWuerfelnMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Timer1.Enabled:=false;

  ImageBecher.Visible:=false;
  WuerfelAnzeigen(true,true);

  //Wurf hochzählen
  Wurf:=Wurf+1;
  if Wurf=3 then
    //Es kann dann nicht nochmal gewürfelt werden
    SpeedButtonWuerfeln.Enabled:=false; //beim 3. Wurf Button deaktivieren

  Wuerfeln(true); //Würfeln, für Würfel auf dem Spielfeld

  SpielInfosAnzeigen;
end;

procedure THauptForm.Timer1Timer(Sender: TObject);
begin
  BecherX:=BecherX+BecherSchritt;
  if (BecherX>5) or (BecherX<0) then BecherSchritt:=BecherSchritt*(-1);
  ImageBecher.Left:=ImageBecher.Tag+BecherX*5;
end;

procedure THauptForm.FormCreate(Sender: TObject);
var
  i : integer;
  s : string;
begin
  //Zufallszahlen-Generator initialisieren
  Randomize;

  //Würfel-Objekte erzeugen
  for i:=1 to 5 do
    begin
      wuerfel[i]:=TWuerfel.Create(nil);
      wuerfel[i].WuerfelShape:=Shape1;
      PanelSpielfeld.InsertControl(wuerfel[i]);
    end;

  //Würfel-Bilder einlesen
  for i:=1 to 6 do
    begin
      WuerfelBild[i]:=TBitmap.Create;
      s:=ExtractFilepath(Paramstr(0))+'w'+IntToStr(i)+'.bmp';
      if FileExists(s)=true then WuerfelBild[i].LoadFromFile(s);
    end;

  //Vorbereitungen
  PunkteLoeschen;
  SpielEnde;
  Meldung('Klicke auf "Neues Spiel", um zu starten.');

  //Dient zum Schütteln des Würfelbechers, zwischenspeichern der Left-Position im Tag
  ImageBecher.Tag:=ImageBecher.Left;
  BecherX:=0;
  BecherSchritt:=1;

  //Titel der Anwendung ändern
  Application.Title:=Spielname;

  //Beschriftung des Fensters ändern
  Caption:=Spielname;
end;

procedure THauptForm.FormDestroy(Sender: TObject);
var i : integer;
begin
  //Aufräumen: erzeugte Objekte wieder zerstören

  //Zuerst die Würfel
  for i:=1 to 5 do
    wuerfel[i].Free;

  //Dann die Würfelbilder
  for i:=1 to 6 do
    WuerfelBild[i].Free;
end;

procedure THauptForm.ListView1DblClick(Sender: TObject);
begin
  WurfEintragen;
end;

end.

