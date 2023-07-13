unit Sempare.Win32.Fiber;

interface

function GetFiberData: pointer;
function GetCurrentFiber: pointer;

implementation

function GetFiberData: pointer;
asm
  {$IFDEF WIN32}
  mov eax, fs:[$10]
  mov eax, [eax]
  {$ENDIF WIN32}
  {$IFDEF WIN64}
  mov     rax, gs:[$20]
  mov     rax, [rax]
  {$ENDIF WIN64}
end;

function GetCurrentFiber: pointer;
asm
  {$IFDEF WIN32}
  mov eax, fs:[$10]
  {$ENDIF WIN32}
  {$IFDEF WIN64}
  mov     rax, gs:[$20]
  {$ENDIF WIN64}
end;

end.
