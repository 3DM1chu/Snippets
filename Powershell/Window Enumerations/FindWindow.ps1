function Find-Window {
    <#
    .Synopsis
        user32dll.FindWindow(className, windowName)
    .Outputs
        @{
           Hwnd
           ThreadProcessId
           Err
        }
    .Example
        Find-Window 'ConsoleWindowClass' 'Windows PowerShell'
        Find-Window ApplicationFrameWindow ???
        fWin 'ConsoleWindowClass' 'Windows PowerShell'
    .Example
        # class only
        Find-Window Notepad
    .Example
        # windowName only
        Find-Window -windowName Calculatrice
        Find-Window -windowName ???
    #>
    [alias('fWin')]
    param (
        [Parameter()]
        [string]$className = "",
        [Parameter()]
        [string]$windowName = ""
    )

    $sig=@'
    // https://stackoverflow.com/a/48698671/9935654
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    
    [DllImport("user32.dll", SetLastError=true)]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindow(string lpClassName, IntPtr lpWindowName);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindow(IntPtr lpClassName, string lpWindowName);

    [DllImport("kernel32.dll")]
    public static extern uint GetLastError();
'@

    $w32 = Add-Type -Namespace Win32 -Name Funcs -MemberDefinition $sig -PassThru
    $cName = if ($className -eq "") {[IntPtr]::Zero} else {$className}
    $wName = if ($windowName -eq "") {[IntPtr]::Zero} else {$windowName}
    $r = $w32::FindWindow($cName, $wName)
    $o = @{
       Hwnd = 0
       ThreadProcessId = 0
       Err = $null
    }
    if ($r -eq [IntPtr]::Zero) {
        $o.Err = $w32::GetLastError()
        return $o
    }
    $o.Hwnd = $r

    # Get the thread process ID
    $processId = 0
    $threadProcessId = [Win32.Funcs]::GetWindowThreadProcessId($r, [ref]$processId)
    $o.ThreadProcessId = $threadProcessId

    return $o
}