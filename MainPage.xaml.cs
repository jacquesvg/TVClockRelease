namespace TvClock;

public partial class MainPage : ContentPage
{
	public MainPage()
	{
		InitializeComponent();
		blazorWebView.BlazorWebViewInitialized += (s, e) =>
		{
			e.WebView.Focusable = true;
			e.WebView.FocusableInTouchMode = true;
			e.WebView.RequestFocus();
		};
	}
}
