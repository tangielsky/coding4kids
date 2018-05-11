unit meinwuerfel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Controls, Graphics;


type
  { TWuerfel }
  TWuerfel = class(TImage) //TWuerfel wird von der Klasse TImage abgeleitet,
  private                  //ist also ein Bild
    FRelPosX,FRelPosY: Integer;//X,Y der Mausposition beim Anklicken
                               //diese brauchen wir zum Verschieben
  public
    Zahl : integer;       //welche Augenzahl hat der Würfel
    WuerfelShape : TShape;//Verbindung zur Würfelfläche des Formulars
    function IstImWuerfelfeld : boolean; //eigene Funktion
    constructor Create(AOwner: TComponent); override;
    procedure Wuerfeln; //eigene Prozedur
  protected
    //eigene Ereignisse
    procedure MouseDown(Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState;
      X,Y: Integer); override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
  end;


var
  //Unsere 5 Würfel als Array
  Wuerfel : array[1..5] of TWuerfel;

  //Würfelbilder von 1 bis 6
  WuerfelBild : array[1..6] of TBitmap;


implementation


constructor TWuerfel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  //Einstellungen eines Würfels
  Height:=80;
  Width:=80;
  Stretch:=true;
  Transparent:=true;
  Proportional:=true;

  //Verknüpftes Würfelfeld als TShape
  WuerfelShape:=nil;
end;


function TWuerfel.IstImWuerfelfeld: boolean;
begin
  //Die Funktion prüft, ob sich der Würfel im verknüpften Würfelfeld befindet

  result:=false;

  //Wenn kein Würfelfeld-Shape verknüpft ist, Funktion verlassen
  if WuerfelShape=nil then exit;


  //Ist Würfel im Feld?
  if (WuerfelShape.Top<=Top) and (WuerfelShape.Left<=Left) and
    (WuerfelShape.Top+WuerfelShape.Height>=Top+Height) and
    (WuerfelShape.Left+WuerfelShape.Width>=Left+Width) then result:=true;
end;

procedure TWuerfel.Wuerfeln;
begin
  //Diese Funktion würfel eine neue Zufallszahl und stellt das Würfelbild ein

  //Zufallszahl ermitteln: 0..5, deshalb +1
  Zahl:=Random(6)+1;

  //Bild einstellen aus dem entsprechenden Würfelbild-Array
  Picture.Bitmap.Assign(WuerfelBild[Zahl]);

  if WuerfelShape=nil then exit;

  //Würfel zufällig im Würfelfeld positionieren
  Top:=WuerfelShape.Top+Random(WuerfelShape.Height-Height);
  Left:=WuerfelShape.Left+Random(WuerfelShape.Width-Width);
end;

procedure TWuerfel.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X,Y: Integer);
begin
  //Wenn Maustaste gedrückt wurde, aktuelle Mausposition merken
  FRelPosX:=X; FRelPosY:=Y;

  //geerbte Methode MouseDown aufrufen
  inherited MouseDown(Button,Shift,X,Y);

  //Würfelbild in den Vordergrund bringen
  BringToFront;
end;

procedure TWuerfel.MouseMove(Shift: TShiftState; X,Y: Integer);
begin
  //geerbte Methode MouseDown aufrufen
  inherited MouseMove(Shift,X,Y);

  //Wird Mausbewegt und ist Linke Maustaste gedrückt, dann Würfel verschieben um
  //die gemerkte Klickposition
  if (ssLeft in Shift) then
    SetBounds(Left+X-FRelPosX,Top+Y-FRelPosY,Width,Height);
end;

procedure TWuerfel.MouseEnter;
begin
  inherited MouseEnter;
  //fährt die Maus über den Würfel, wird der Mauszeiger zur Hand
  Cursor:=crHandPoint;
end;

procedure TWuerfel.MouseLeave;
begin
  inherited MouseLeave;
  //verlässt der Mauszeiger den Würfel, wird der Mauszeiger wieder normal
  Cursor:=crDefault;
end;


end.

