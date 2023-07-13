# Sempare FiberGenerator

Copyright (C) 2022 Conrad Vermeulen, Sempare Limited

License: MIT License

This is a demonstration of using fibers under Windows.

Fibers are not commonly used, but in certain circumstances are quite useful. Fibers are seen as light weight threads,
where scheduling is managed by the developer and not by the operating system. This is where it makes things complicated for most developers.
They are fast as there is no context switching to the system.

This description is not going to go into the pros/cons of using fibers, but will just illustrate the utilisation in the form of
a generator pattern that people may have seen in languages like Python.

A use case that I've found particularly useful is where you want to make asynchronous functions appear as synchronous functions.

src/Sempare.Win32.Fiber.pas contains some missing functions (GetFiberData, GetCurrentFiber) that are not included with the RTL Windows units at present (Delphi 11.3).

This works in Win32 and Win64.

This example illustrates the utilisation of fibers - note the problem can be solved more simply using normal language constructs.

# The generator example

Assume you want to have a function that just produces numbers continually. You do not have to care about when it completes.

In this example, generic TGenerator<T> is provided that controls the sequence being generate.

The generator needs a procedure that produces values. In order to return a value, the TGenerator<T>.Yield(value) must be called.

Further the generator has an end action - it can either raise an exception, or resume generating values from the begining.

## A simple sequence

```
procedure SeqProducer();
begin
  TGenerator<integer>.Yield(1);
  TGenerator<integer>.Yield(2);
  TGenerator<integer>.Yield(3);
end;

procedure TestSeq;
var
  LGenerator: TGenerator<integer>;
  i: integer;
begin
  LGenerator.Producer := SeqProducer;
  // 1,2,3,1,2,3,1,2,3,1
  for i := 1 to 10 do
    writeln(inttostr(G.Value));
end;
```


## Fibonacci

```
procedure FibonaciProducer();
var
  i, j, t: integer;
begin
  i := 1; j := 1;
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

procedure TestFibonnaci;
var
  LGenerator: TGenerator<integer>;
  i: integer;
begin
  LGenerator.Producer := FibonaciProducer;
  for i := 1 to 10 do
    writeln(inttostr(G.Value));
end;
```

# Enforcing one time iteration of values

The TGenerator<T>.EndAction can be set to geaException. If you attempt to consume more values than the producer has to offer, an exception is raised.


```
procedure SeqProducer();
begin
  TGenerator<integer>.Yield(1);
  TGenerator<integer>.Yield(2);
  TGenerator<integer>.Yield(3);
end;

procedure TestFibonnaci;
var
  LGenerator: TGenerator<integer>;
  i: integer;
begin
  LGenerator.Producer := SeqProducer;
  LGenerator.EndAction := geaException;
  for i := 1 to 3 do
    writeln(inttostr(G.Value));
  try
        writeln(inttostr(G.Value)); // exception will be thrown
  except on e:Exception do
        writeln('Exception was raised');
  end;
end;
```
