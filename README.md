# Unity & Azure Pipelines Demo: Lost Crypt

This project demonstrates building a Unity app for iOS/Android with [Azure Pipelines](https://azure.microsoft.com/en-us/services/devops/pipelines/) and [Unity Build Server](https://unity.com/products/unity-build-server).
The sample app is based on [Lost Crypt - 2D Sample Project](https://assetstore.unity.com/packages/essentials/tutorial-projects/lost-crypt-2d-sample-project-158673) from Unity Technologies.
It's distributed under [the Unity Companion License](https://unity3d.com/jp/legal/licenses/Unity_Companion_License).

## Azure Pipelines

[The public project on Azure DevOps](https://dev.azure.com/bananedemo/LostCrypt) has [CI/CD pipelines](https://dev.azure.com/bananedemo/LostCrypt/_build) for this repository.
You can see actual build logs for 2 target platforms and 2 configurations.

|Platform|Development|Release|
|---|---|---|
|Android|[![Build Status](https://dev.azure.com/bananedemo/LostCrypt/_apis/build/status/LostCrypt%20Android%20Development?branchName=master)](https://dev.azure.com/bananedemo/LostCrypt/_build/latest?definitionId=11&branchName=master)|[![Build Status](https://dev.azure.com/bananedemo/LostCrypt/_apis/build/status/LostCrypt%20Android%20Release?branchName=master)](https://dev.azure.com/bananedemo/LostCrypt/_build/latest?definitionId=10&branchName=master)|
|iOS|[![Build Status](https://dev.azure.com/bananedemo/LostCrypt/_apis/build/status/LostCrypt%20iOS%20Development?branchName=master)](https://dev.azure.com/bananedemo/LostCrypt/_build/latest?definitionId=13&branchName=master)|[![Build Status](https://dev.azure.com/bananedemo/LostCrypt/_apis/build/status/LostCrypt%20iOS%20Release?branchName=master)](https://dev.azure.com/bananedemo/LostCrypt/_build/latest?definitionId=12&branchName=master)|

YAML pipeline files reside in [AzureDevOps/Scripts](AzureDevOps/Scripts)
and the following files are the entrypoints.

- [pipeline-android.yml](AzureDevOps/Pipelines/pipeline-android.yml)
- [pipeline-ios.yml](AzureDevOps/Pipelines/pipeline-ios.yml)

The pipelines consume the following variables defined in `unity-build` variable group.

|Name|Example Value|Description|
|---|---|---|
|`appcenterEndpoint`|`AppCenter-LostCrypt`|App Center endpoint base name<br/>(`-TARGET-CONFIG` is appended)|
|`appcenterGroupId`|`XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`|App Center distribute group ID|
|`appcenterSlug`|`bananedemo/LostCrypt`|App Center project slug base name<br/>(`-TARGET-CONFIG` is appended)|
|`p12Pwd`|`secret`|iOS code signing p12 file password|
|`p12SecureFile`|`cert.p12`|iOS code signing p12 secure file name|
|`provSecureFile`|`prov.mobileprovision`|iOS mobile provisioning secure file name|
|`unityTunnelKeySecureFile`|`privkey.pem`|SSH private key secure file name|
|`unityTunnelServer`|`user@license.example.com`|SSH user@host to connect the license server|

You have to upload secure files with the name disignated by variables above.

## App Center Distribute

Here are the public app distribution pages by Visual Studio App Center.  Note that iOS apps won't work on your devices because the issued mobile provisionings are limited to mine.

- [bananedemo/LostCrypt-Android-Development](https://install.appcenter.ms/orgs/bananedemo/apps/lostcrypt-android-development/distribution_groups/public)
- [bananedemo/LostCrypt-Android-Release](https://install.appcenter.ms/orgs/bananedemo/apps/lostcrypt-android-release/distribution_groups/public)
- [bananedemo/LostCrypt-iOS-Development](https://install.appcenter.ms/orgs/bananedemo/apps/lostcrypt-ios-development/distribution_groups/public)
- [bananedemo/LostCrypt-iOS-Release](https://install.appcenter.ms/orgs/bananedemo/apps/lostcrypt-ios-release/distribution_groups/public)
