using Microsoft.Win32;

namespace EplanUtilities
{
    public enum WindowsTheme
    {
        Light,
        Dark
    }

    public static class SettingUtility
    {
        public static WindowsTheme GetEplanColorTheme()
        {
            var o_Settings = new Eplan.EplApi.Base.Settings();

            try
            {
                int colorScheme = o_Settings.GetNumericSetting("USER.MF.GuiColorScheme", 0);

                switch (colorScheme)
                {
                    case 0:
                        return GetWindowsThemeFromRegistry();
                    case 1:
                        return WindowsTheme.Dark;
                    case 2:
                        return WindowsTheme.Light;
                    default:
                        return WindowsTheme.Light;
                }
            }
            catch
            {
            }

            return WindowsTheme.Light;
        }

        private static WindowsTheme GetWindowsThemeFromRegistry()
        {
            try
            {
                int? registryValue = Registry.GetValue(
                    @"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize",
                    "AppsUseLightTheme",
                    null) as int?;

                if (registryValue.HasValue)
                {
                    return registryValue.Value == 0 ? WindowsTheme.Dark : WindowsTheme.Light;
                }
            }
            catch
            {
            }

            return WindowsTheme.Light;
        }
    }
}
