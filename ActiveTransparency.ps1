Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Win32 {
    // DWM API Functions
    [DllImport("dwmapi.dll", CharSet = CharSet.Auto)]
    public static extern int DwmExtendFrameIntoClientArea(IntPtr hwnd, ref MARGINS pMarInset);

    [DllImport("dwmapi.dll")]
    public static extern int DwmIsCompositionEnabled(out bool pfEnabled);

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    // Struct for MARGINS
    [StructLayout(LayoutKind.Sequential)]
    public struct MARGINS {
        public int Left;
        public int Right;
        public int Top;
        public int Bottom;
    }

    // Function to enable transparency on a window
    public static void ApplyDwmTransparency(IntPtr hwnd) {
        MARGINS margins = new MARGINS() { Left = -1, Right = -1, Top = -1, Bottom = -1 };
        DwmExtendFrameIntoClientArea(hwnd, ref margins);
    }

    // Function to enable transparency globally (i.e., for the taskbar, explorer, etc.)
    public static void ApplyGlobalTransparency() {
        // Apply transparency to the taskbar and Explorer windows
        IntPtr hwnd = GetForegroundWindow();
        ApplyDwmTransparency(hwnd);
    }
}
"@

# Function to apply transparency to all open windows
function Apply-TransparencyToWindows {
    # Get all open windows
    $windows = Get-Process | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero }

    foreach ($window in $windows) {
        [Win32]::ApplyDwmTransparency($window.MainWindowHandle)
    }
}

# Function to apply transparency to the taskbar and core UI elements
function Apply-TransparencyToTaskbar {
    # Apply to Taskbar (Explorer handle)
    $taskbarHandle = (Get-Process explorer | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero }).MainWindowHandle
    [Win32]::ApplyDwmTransparency($taskbarHandle)

    # Apply to other DWM-managed UI elements (Explorer)
    [Win32]::ApplyGlobalTransparency()
}

# Continuous loop to apply transparency
while ($true) {
    Apply-TransparencyToWindows
    Apply-TransparencyToTaskbar
    Start-Sleep -Seconds 1 # Adjust the interval if needed
}
