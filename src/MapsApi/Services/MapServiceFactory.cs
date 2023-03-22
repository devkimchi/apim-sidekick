using System.Collections.Generic;
using System.Net.Http;

using ApimSidekick.MapsApi.Configs;

namespace ApimSidekick.MapsApi.Services
{
    /// <summary>
    /// This represents the factory entity for <see cref="IMapService"/> instances.
    /// </summary>
    public class MapServiceFactory : IMapServiceFactory
    {
        private readonly Dictionary<string, IMapService> _services;

        /// <summary>
        /// Initializes a new instance of the <see cref="MapServiceFactory"/> class.
        /// </summary>
        /// <param name="settings"><see cref="MapsSettings"/> instance.</param>
        /// <param name="factory"><see cref="IHttpClientFactory"/> instance.</param>
        public MapServiceFactory(MapsSettings settings, IHttpClientFactory factory)
        {
            this._services = new Dictionary<string, IMapService>()
            {
                { MockMapService.Name, new MockMapService(settings, factory) },
                { GoogleMapService.Name, new GoogleMapService(settings, factory) },
            };
        }

        /// <inheritdoc/>
        public IMapService GetMapService(string name)
        {
            if (!this._services.ContainsKey(name))
            {
                return null;
            }

            return this._services[name];
        }
    }
}