using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;
using YamlDotNet.Core;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;

namespace AppBuilder
{

    public static class Tasks
    {
        const string DefaultConfigName = "Development";
        const string DefaultBuildSettingsPath = "buildSettings.yml";

        private static void CommandLineBuild()
        {
            string configName = DefaultConfigName;
            string settingsPath = DefaultBuildSettingsPath;
            string[] args = Environment.GetCommandLineArgs();
            for (var i = 1; i < args.Length; i++)
            {
                switch (args[i])
                {
                    case "-settings":
                        if (i < args.Length - 1) { settingsPath = args[i + 1]; }
                        break;
                    case "-config":
                        if (i < args.Length - 1) { configName = args[i + 1]; }
                        break;
                }
            }
            var result = BuildMain(settingsPath, configName);
            EditorApplication.Exit(result ? 0 : 1);
        }

        [MenuItem("AppBuilder/Build Development")]
        private static void MenuBuildDevelopment()
        {
            BuildMain(DefaultBuildSettingsPath, "Development");
        }

        [MenuItem("AppBuilder/Build Release")]
        private static void MenuBuildRelease()
        {
            BuildMain(DefaultBuildSettingsPath, "Release");
        }

        private static Config LoadSettings(string settingsPath, string configName)
        {
            var builder = new DeserializerBuilder().WithNamingConvention(new CamelCaseNamingConvention());
            var deserializer = builder.Build();
            var settings = new Dictionary<string, Config>();
            using (var file = new StreamReader(settingsPath, Encoding.UTF8))
            {
                settings = deserializer.Deserialize<Dictionary<string, Config>>(new MergingParser(new Parser(file)));
            }
            if (!settings.ContainsKey(configName))
            {
                throw new Exception($"Configuration {configName} not found");
            }
            return settings[configName];
        }

        private static bool BuildMain(string settingsPath, string configName)
        {
            try
            {
                Debug.LogFormat("BUILD STARTED\n");
                var config = LoadSettings(settingsPath, configName);
                PlayerSettings.productName = config.productName;
                PlayerSettings.companyName = config.companyName;
                PlayerSettings.bundleVersion = config.bundleVersion;
                PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.Android, config.android.identifier);
                PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.iOS, config.iOS.identifier);
                PlayerSettings.iOS.appleEnableAutomaticSigning = config.iOS.automaticSigning;
                PlayerSettings.iOS.appleDeveloperTeamID = config.iOS.developerTeamId;
                var options = new BuildPlayerOptions
                {
                    target = EditorUserBuildSettings.activeBuildTarget,
                    scenes = config.scenes,
                };
                if (config.developmentBuild)
                {
                    options.options |= BuildOptions.Development;
                }
                switch (options.target)
                {
                    case BuildTarget.Android:
                        options.locationPathName = config.android.outputPath;
                        break;
                    case BuildTarget.iOS:
                        options.locationPathName = config.iOS.outputPath;
                        break;
                }
                var report = BuildPipeline.BuildPlayer(options);
                if (report.summary.result == BuildResult.Succeeded)
                {
                    Debug.LogFormat("BUILD SUCCEEDED\n{0}", report.summary.ToString());
                    return true;
                }
                else
                {
                    Debug.LogErrorFormat("BUILD FAILED\n{0}", report.summary.ToString());
                    return false;
                }
            }
            catch (Exception e)
            {
                Debug.LogErrorFormat("BUILD FAILED\n{0}", e.ToString());
                return false;
            }
        }
    }

}
