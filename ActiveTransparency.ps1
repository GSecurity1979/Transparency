Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    // Struct for ACCENT_POLICY
    [StructLayout(LayoutKind.Sequential)]
    public struct ACCENT_POLICY {
        public int nAccentState;
        public int nFlags;
        public int nColor;
        public int nAnimationId;
    }

    // Struct for WINDOW_COMPOSITION_ATTRIBUTE_DATA
    [StructLayout(LayoutKind.Sequential)]
    public struct WINDOW_COMPOSITION_ATTRIBUTE_DATA {
        public int nAttribute;
        public IntPtr pData;
        public int nDataSize;
    }

    // DllImport to call SetWindowCompositionAttribute API
    [DllImport("user32.dll")]
    public static extern int SetWindowCompositionAttribute(IntPtr hwnd, ref WINDOW_COMPOSITION_ATTRIBUTE_DATA data);

    // Function to set window transparency
    public static void SetTransparency(IntPtr hwnd, int opacity) {
        var accent = new ACCENT_POLICY { 
            nAccentState = 3, // ACCENT_ENABLE_TRANSPARENTGRADIENT
            nColor = 0x00000000, // No color for transparency
            nFlags = 2, // Apply transparency
            nAnimationId = 0 
        };

        // Adjust transparency (opacity) - where 255 is fully opaque, and 0 is fully transparent
        accent.nColor = (int)(255 * opacity / 100); // Set opacity, e.g., 80% opacity.

        var accentSize = Marshal.SizeOf(accent);
        var accentPtr = Marshal.AllocHGlobal(accentSize);
        Marshal.StructureToPtr(accent, accentPtr, false);

        var data = new WINDOW_COMPOSITION_ATTRIBUTE_DATA {
            nAttribute = 19, // WCA_ACCENT_POLICY
            pData = accentPtr,
            nDataSize = accentSize
        };

        // Apply the transparency to the window
        SetWindowCompositionAttribute(hwnd, ref data);
        Marshal.FreeHGlobal(accentPtr);
    }

    // Function to apply transparency to all open windows
    public static void ApplyTransparencyToAllWindows() {
        var processes = System.Diagnostics.Process.GetProcesses();
        foreach (var process in processes) {
            if (process.MainWindowHandle != IntPtr.Zero) {
                SetTransparency(process.MainWindowHandle, 80); // Set 80% opacity
            }
        }
    }
}
"@

# Apply 80% transparency to all open windows
[Win32]::ApplyTransparencyToAllWindows()
