# 🎯 Blazor MAUI Hybrid MVP for Android TV (Sideloaded)

No existing workspace code was found; this is a greenfield project. Target: .NET 10, Android-only, Android TV (leanback), single page with a D-pad-focusable button that shows a static snapshot of `DateTime.Now` in device locale format. Distribution: signed release APK transferred via Send Files to TV / Downloader.

Key Android TV requirements:
- Manifest must declare `android.software.leanback` (required=false is fine for sideload, but launcher needs `LEANBACK_LAUNCHER` category) and `android.hardware.touchscreen` required=false.
- A TV banner (320x180 px) via `android:banner` so the app shows on the TV home screen.
- D-pad navigation: the WebView must be focusable; the button should get autofocus and a visible `:focus` style.
- Release APK (not AAB) with `AndroidPackageFormat=apk`, signed with a self-generated keystore.

Risks: .NET 10 requires the matching MAUI workload and Android SDK API 35/36; some older Android TV devices run Android 9 or earlier (set `SupportedOSPlatformVersion` to 24 or lower, as minimum for MAUI). The WebView on TVs may be outdated; Android System WebView updates may be needed.

**Progress**: 60% [██████░░░░]

**Last Updated**: 2026-11-24 19:11:10

## 📝 Plan Steps
- ✅ **Install prerequisites — .NET 10 SDK, `dotnet workload install maui-android`, Android SDK/JDK (via Visual Studio installer); enable Developer options on the TV (optional, for debugging).**
- ✅ **Create project — `dotnet new maui-blazor -n TvClock -f net10.0`; in the .csproj, set `TargetFrameworks` to `net10.0-android` only, `SupportedOSPlatformVersion` 24, `ApplicationId` e.g. `com.yourname.tvclock`.**
- ✅ **Remove unused platforms — delete `Platforms/iOS`, `Platforms/MacCatalyst`, `Platforms/Windows`, `Platforms/Tizen`.**
- ✅ **Update `Platforms/Android/AndroidManifest.xml` — add `<uses-feature android:name="android.software.leanback" android:required="false"/>` and `<uses-feature android:name="android.hardware.touchscreen" android:required="false"/>`; set `android:banner="@drawable/tv_banner"` on `<application>`.**
- ✅ **Add TV banner — place a 320x180 PNG at `Platforms/Android/Resources/drawable/tv_banner.png`.**
- ✅ **Update `Platforms/Android/MainActivity.cs` — add `[IntentFilter(new[] { Intent.ActionMain }, Categories = new[] { Intent.CategoryLauncher, Intent.CategoryLeanbackLauncher })]` and set `ScreenOrientation = ScreenOrientation.Landscape`.**
- ✅ **Simplify UI — replace `Components/Pages/Home.razor` with a page containing a large button (`autofocus`, `@onclick="ShowTime"`) and a `<p>` that shows `snapshot?.ToString(CultureInfo.CurrentCulture)`; set `snapshot = DateTime.Now` in `ShowTime`.**
- ✅ **Strip layout — remove the nav menu/sidebar from `MainLayout.razor`, delete Counter/Weather pages, and remove the default template padding.**
- ✅ **Style for TV — in `wwwroot/css/app.css` use large fonts (≥ 48px), a high-contrast `:focus` outline on the button, centered layout, and 5% overscan-safe margins.**
- 🔄 **Ensure D-pad focus — in `MainPage.xaml.cs`/BlazorWebView `BlazorWebViewInitialized` handler, call `webView.Focusable = true; webView.RequestFocus();` on the Android WebView so the remote's OK key triggers the button.**
-  **Create signing keystore — `keytool -genkeypair -v -keystore tvclock.keystore -alias tvclock -keyalg RSA -keysize 2048 -validity 10000`; keep it outside source control.**
-  **Configure release signing — in .csproj Release group: `AndroidPackageFormat=apk`, `AndroidKeyStore=true`, `AndroidSigningKeyStore`, `AndroidSigningKeyAlias`, and the passwords supplied through `env:` references.**
-  **Build APK — `dotnet publish -f net10.0-android -c Release`; output `*-Signed.apk` in `bin/Release/net10.0-android/publish`.**
-  **Sideload — on the TV, enable "Install unknown apps" for Send Files to TV/Downloader; send the APK from phone/PC (or host it and enter the URL in Downloader), then install.**
-  **Verify — launch from the TV home row (banner visible), press OK on the remote, and confirm the date/time displays in the TV's locale format.**

