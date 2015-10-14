unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.TypInfo, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type TPessoa = class(Tpersistent)
  private
    FIdade: Integer;
    FNome: String;
    FData: TDateTime;
    procedure SetData(const Value: TDateTime);
    procedure SetIdade(const Value: Integer);
    procedure SetNome(const Value: String);

  published
    property Nome: String read FNome write SetNome;
    property Idade: Integer read FIdade write SetIdade;
    property Data: TDateTime read FData write SetData;
end;

type TBindRec = record
  obj: TPersistent;
  prop: String;
  valor: variant;
  data: TDateTime;
end;

type TProc = function (objOrig, objDest: TBindRec):boolean of object;

type TBind = class
  private
    _objOrigem: TBindRec;
    _objDestino: TBindRec;
    function _execute(objOrig, objDest: TBindRec): Boolean;
  public
    Execute :Tproc;
    constructor Create(objOrigem: TbindRec; objDestino:TbindRec);


end;

type TBindController = class
  private
    _binds : Array of Tbind;
    _timer: TTimer;
    procedure onTimer(Sender: TObject);
  public
    constructor Create();
    procedure Add(bind: Tbind);

end;


type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    TrackBar1: TTrackBar;
    ProgressBar1: TProgressBar;
    Edit3: TEdit;
    Edit4: TEdit;
    Button2: TButton;
    DateTimePicker1: TDateTimePicker;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    BindController : TBindController;
  public
    { Public declarations }
    pessoa: TPessoa;
    function ConversaoData(objOrig, objDest: TBindRec):Boolean;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ TBind }

constructor TBind.Create(objOrigem: TbindRec; objDestino: TbindRec);
begin
  _objOrigem := objOrigem;
  _objDestino := objDestino;
  execute := _execute;
end;

function TBind._execute(objOrig, objDest: TBindRec): Boolean;
  var value: variant;
begin
  try
    value := GetPropValue( objOrig.obj, objOrig.prop );
    SetPropValue(objDest.obj, objDest.prop, value);
    result := True;
  except
    result := false;
  end;
end;

{ TBindController }

procedure TBindController.Add(bind: Tbind);
  var pos: integer;
begin
  pos := length( _binds )+1;
  SetLength(_binds, pos);
  _binds[pos-1] := bind;
end;

constructor TBindController.Create;
begin
  _timer := TTimer.Create(nil);
  _timer.OnTimer := ontimer;
  _timer.Interval := 100;
end;

procedure TBindController.onTimer(Sender: TObject);
  var i: integer;
begin

  for i := 0 to Length(_binds)-1 do
  begin
    _binds[i].Execute(_binds[i]._objOrigem, _binds[i]._objDestino);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
  var bind: Tbind;
    origem, destino: TBindRec;

  function NewBindRec(obj: TPersistent; Prop: String):TBindRec;
  begin
    result.obj := obj;
    result.prop := prop;
  end;

  function NewBind(objOrigem: TPersistent; propOrigem: String; objDestino: TPersistent; propDestino: String): TBind;
  begin
    result := TBind.Create( newbindrec(objOrigem, PropOrigem), newbindrec(objDestino, PropDestino));
  end;

begin
  BindController := TBindController.Create;
  pessoa := TPessoa.Create;
  BindController.Add(newbind(edit1,'text', pessoa,'nome'));
  BindController.Add(newbind(TrackBar1,'position', pessoa,'idade'));

  bind := newbind(edit3,'text', pessoa,'data');
  bind.Execute := ConversaoData;

  BindController.Add(bind);

  BindController.Add(newbind(pessoa,'nome', label1,'caption'));
  BindController.Add(newbind(pessoa,'Idade', label2,'caption'));


  BindController.Add(newbind(pessoa,'data', DateTimePicker1,'date'));

  bindcontroller.Add(newbind(pessoa,'idade', ProgressBar1,'position'));

//  origem.obj := edit1;
//  origem.prop := 'text';
//
//  destino.obj := label1;
//  destino.prop := 'caption';
//
//  bind := tbind.Create(  origem, destino );
//
//  BindController.Add( bind );
//  bindcontroller.Add( tbind.Create(newBindRec(edit2,'text'), newbindrec(label2,'caption')) );
//  bindController.Add( newBind( edit1, 'text', self, 'caption' ) );
//  bindcontroller.Add( newBind(TrackBar1, 'position', ProgressBar1, 'position') );
//
//  BindController.Add( newbind(edit3,'text',edit4, 'text') );

end;

{ Tpessoas }

procedure TPessoa.SetData(const Value: TDateTime);
begin
  FData := Value;
end;

procedure TPessoa.SetIdade(const Value: Integer);
begin
  FIdade := Value;
end;

procedure TPessoa.SetNome(const Value: String);
begin
  FNome := Value;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  showmessage(pessoa.Nome);
end;

function TForm1.ConversaoData(objOrig, objDest: TBindRec): Boolean;
  var value: variant;
begin
  try
    value :=  GetPropValue( objOrig.obj, objOrig.prop );
    SetPropValue(objDest.obj, objDest.prop, StrToDate( value ) );
    result := True;
  except
    result := false;
  end;
end;

end.
