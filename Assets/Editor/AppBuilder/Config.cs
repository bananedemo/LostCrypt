namespace AppBuilder
{
    public class ConfigAndroid
    {
        public string identifier { get; set; }
        public string outputPath { get; set; }
    }

    public class ConfigIOS
    {
        public string identifier { get; set; }
        public string outputPath { get; set; }
        public bool automaticSigning { get; set; }
        public string developerTeamId { get; set; }
    }

    public class Config
    {
        public string productName { get; set; }
        public string companyName { get; set; }
        public string bundleVersion { get; set; }
        public bool developmentBuild { get; set; }
        public string[] scenes { get; set; }
        public ConfigAndroid android { get; set; }
        public ConfigIOS iOS { get; set; }
    }
}
