unit Sempare.FiberGenerator;

interface

uses
  System.SysUtils;

type
  EEndofGenerator = class(Exception);

  TGenEndAction = (geaException, geaResume);

  TGenerator<T> = record
  private
    FMain: pointer;
    FFiber: pointer;
    FValue: T;
    FFunc: TProc;
    FEndAction: TGenEndAction;
    FDone: boolean;
    function GetValue: T;
    class procedure GeneratorWrapper(var AGenerator: TGenerator<T>); stdcall; static;
  public

    class procedure Yield(const AValue: T); static;

    class operator Initialize(out AGenerator: TGenerator<T>);
    class operator Finalize(var AGenerator: TGenerator<T>);
    class operator Assign(var ADest: TGenerator<T>; var ASrc: TGenerator<T>);

    property Current: pointer read FMain;
    property Fiber: pointer read FFiber;
    property Value: T read GetValue;
    property Producer: TProc read FFunc write FFunc;
    property EndAction: TGenEndAction read FEndAction write FEndAction;
  end;

implementation

uses
  Windows,
  Sempare.Win32.Fiber;

class procedure TGenerator<T>.Yield(const AValue: T);
var
  LGenerator: ^TGenerator<T>;
  LGeneratorPtr: pointer absolute LGenerator;
begin
  LGeneratorPtr := GetFiberData;
  LGenerator.FValue := AValue;
  SwitchToFiber(LGenerator.Current);
end;

class procedure TGenerator<T>.GeneratorWrapper(var AGenerator: TGenerator<T>);
begin
  AGenerator.FDone := false;
  AGenerator.Producer();
  AGenerator.FDone := true;
  SwitchToFiber(AGenerator.Current);
end;

{ TGenerator }

class operator TGenerator<T>.Assign(var ADest, ASrc: TGenerator<T>);
begin
  move(ASrc, ADest, sizeof(TGenerator<T>));
  // we nil the fiber so that it is not destructed during copy operations
  ASrc.FFiber := nil;
end;

class operator TGenerator<T>.Finalize(var AGenerator: TGenerator<T>);
begin
  if AGenerator.FFiber <> nil then
  begin
    DeleteFiber(AGenerator.FFiber);
    ConvertFiberToThread();
    AGenerator.FFiber := nil;
  end;
end;

function TGenerator<T>.GetValue: T;
begin
  SwitchToFiber(FFiber);
  if FDone then
  begin
    if FEndAction = geaResume then
    begin
      DeleteFiber(FFiber);
      FFiber := CreateFiber(0, @GeneratorWrapper, @self);
      SwitchToFiber(FFiber);
      exit(FValue);
    end;

    if FEndAction = geaException then
    begin
      raise EEndofGenerator.Create('Reached end of generator');
    end;
  end;
  exit(FValue);
end;

class operator TGenerator<T>.Initialize(out AGenerator: TGenerator<T>);
begin
  fillchar(AGenerator, sizeof(AGenerator), 0);
  AGenerator.FEndAction := geaResume;
  ConvertThreadToFiber(@AGenerator);
  AGenerator.FMain := GetCurrentFiber;
  AGenerator.FFiber := CreateFiber(0, @GeneratorWrapper, @AGenerator);
end;

end.
