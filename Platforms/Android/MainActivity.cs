using Android.App;
using Android.Content;
using Android.Content.PM;
using Android.OS;

namespace TvClock;

[Activity(Theme = "@style/Maui.SplashTheme", MainLauncher = true, Exported = true, ScreenOrientation = ScreenOrientation.Landscape, ConfigurationChanges = ConfigChanges.ScreenSize | ConfigChanges.Orientation | ConfigChanges.UiMode | ConfigChanges.ScreenLayout | ConfigChanges.SmallestScreenSize | ConfigChanges.Density)]
[IntentFilter(new[] { Intent.ActionMain }, Categories = new[] { Intent.CategoryLauncher, Intent.CategoryLeanbackLauncher })]
public class MainActivity : MauiAppCompatActivity
{
}
