Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [StructLayout(LayoutKind.Sequential)]
    public struct ACCENT_POLICY {
        public int nAccentState;
        public int nFlags;
        public int nColor;
        public int nAnimationId;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct WINDOW_COMPOSITION_ATTRIBUTE_DATA {
        public int nAttribute;
        public IntPtr pData;
        public int nDataSize;
    }

    [DllImport("user32.dll")]
    public static extern int SetWindowCompositionAttribute(IntPtr hwnd, ref WINDOW_COMPOSITION_ATTRIBUTE_DATA data);

    public static void SetTransparency(IntPtr hwnd) {
        var accent = new ACCENT_POLICY { nAccentState = 3 }; // ACCENT_ENABLE_TRANSPARENTGRADIENT
        var accentSize = Marshal.SizeOf(accent);
        var accentPtr = Marshal.AllocHGlobal(accentSize);
        Marshal.StructureToPtr(accent, accentPtr, false);

        var data = new WINDOW_COMPOSITION_ATTRIBUTE_DATA {
            nAttribute = 19, // WCA_ACCENT_POLICY
            pData = accentPtr,
            nDataSize = accentSize
        };

        SetWindowCompositionAttribute(hwnd, ref data);
        Marshal.FreeHGlobal(accentPtr);
    }
}
"@

# Function to apply transparency to all open windows
function Apply-TransparencyToWindows {
    # Get all open windows
    $windows = Get-Process | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero }

    foreach ($window in $windows) {
        [Win32]::SetTransparency($window.MainWindowHandle)
    }
}

# Function to apply transparency to the taskbar
function Apply-TransparencyToTaskbar {
    $taskbarHandle = (Get-Process explorer | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero }).MainWindowHandle
    [Win32]::SetTransparency($taskbarHandle)
}

# Continuous loop to apply transparency
while ($true) {
    Apply-TransparencyToWindows
    Apply-TransparencyToTaskbar
    Start-Sleep -Seconds 1 # Adjust the interval if needed
}
