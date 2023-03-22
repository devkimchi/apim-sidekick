namespace ApimSidekick.MapsApi.Configs
{
    /// <summary>
    /// This represents the app settings entity for map services.
    /// </summary>
    public class MapsSettings
    {
        /// <summary>
        /// Gets the app settings attribute name.
        /// </summary>
        public const string Name = "Maps";

        /// <summary>
        /// Gets or sets the <see cref="GoogleMapsSettings"/> instance.
        /// </summary>
        public virtual GoogleMapsSettings Google { get; set; } = new GoogleMapsSettings();
    }

    /// <summary>
    /// This represents the app settings entity for Google Maps API.
    /// </summary>
    public class GoogleMapsSettings
    {
        /// <summary>
        /// Gets or sets the API key.
        /// </summary>
        public virtual string ApiKey { get; set; }
    }
}