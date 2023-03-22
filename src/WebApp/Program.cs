using ApimSidekick.WebApp;
using ApimSidekick.WebApp.Configs;

using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) });

var settings = new AppSettings();
builder.Configuration.Bind(settings);
builder.Services.AddSingleton(settings);

// builder.Services.AddSingleton(sp => sp.GetService<IConfiguration>().GetSection(LinksSettings.Name).Get<LinksSettings>());
// builder.Services.AddSingleton(sp => sp.GetService<IConfiguration>().GetSection(EndpointsSettings.Name).Get<EndpointsSettings>());

builder.Services.AddGeolocationServices();

await builder.Build().RunAsync();
