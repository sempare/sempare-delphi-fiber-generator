unit Sempare.FiberGenerator.Test;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TGeneratorTest = class
  public
    [Test]
    procedure TestContinuousFixedRange;

    [Test]
    procedure TestFibonacci;

    [Test]
    procedure TestStrictFixedRange;
  end;

implementation

uses
  System.SysUtils,
  Sempare.FiberGenerator;

{ TGeneratorTest }

procedure TGeneratorTest.TestContinuousFixedRange;
var
  LGenerator: TGenerator<integer>;
  i, j: integer;
begin
  LGenerator.Producer := procedure
    begin
      TGenerator<integer>.Yield(1);
      TGenerator<integer>.Yield(2);
      TGenerator<integer>.Yield(3);
    end;
  for i := 0 to 9 do
  begin
    j := LGenerator.Value;
    assert.AreEqual(i mod 3 + 1, j);
  end;
end;

procedure TGeneratorTest.TestFibonacci;
var
  LGenerator: TGenerator<integer>;
  LSeq: TArray<integer>;
  i, j: integer;
begin
  LGenerator.Producer := procedure
    var
      i, j, t: integer;
    begin
      i := 1;
      j := 1;
      TGenerator<integer>.Yield(1);
      TGenerator<integer>.Yield(1);
      while true do
      begin
        t := i + j;
        TGenerator<integer>.Yield(t);
        i := j;
        j := t;
      end;
    end;
  LSeq := [1, 1, 2, 3, 5, 8, 13, 21, 34, 55];
  for i := 0 to 9 do
  begin
    j := LGenerator.Value;
    assert.AreEqual(LSeq[i], j);
  end;
end;

procedure TGeneratorTest.TestStrictFixedRange;
var
  LGenerator: TGenerator<integer>;
begin
  LGenerator.Producer := procedure
    begin
      TGenerator<integer>.Yield(1);
      TGenerator<integer>.Yield(2);
      TGenerator<integer>.Yield(3);
    end;
  LGenerator.EndAction := geaException; // force exception if we try to pull move values than produced
  assert.AreEqual(1, LGenerator.Value);
  assert.AreEqual(2, LGenerator.Value);
  assert.AreEqual(3, LGenerator.Value);
  assert.WillRaise(
    procedure
    var
      i: integer;
    begin
      i := LGenerator.Value; // this should throw
    end);
end;

initialization

TDUnitX.RegisterTestFixture(TGeneratorTest);

end.
