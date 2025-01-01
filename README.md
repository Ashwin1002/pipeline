# Android and iOS Workflow

This document outlines the Continuous Deployment (CD) process using GitHub Actions and Xcode Cloud to upload an app bundle to the Play Store and an IPA to TestFlight.

---

## Table of Contents

1. [Getting Started with Workflows](#getting-started-with-workflows)
2. [Understanding Actions and Workflows](#understanding-actions-and-workflows)
3. [Android Setup](#android-setup)
   - [Setting up Keystore and Key Properties](#setting-up-keystore-and-key-properties)
   - [Configuring GitHub Secrets](#configuring-github-secrets)
   - [Uploading to Play Store](#uploading-to-play-store)
4. [Folder Structure and Workflow Files](#folder-structure-and-workflow-files)
5. [Updating Workflows](#updating-workflows)
6. [iOS Setup](#ios-workflow)
7. [Additional Resources](#additional-resources)

---

## Getting Started with Workflows

GitHub Actions allows you to automate workflows directly from your repository. To learn more about writing and managing workflows, refer to the [official GitHub Actions documentation](https://docs.github.com/en/actions/writing-workflows).

---

## Understanding Actions and Workflows

**Workflows** are automated processes that you define in your GitHub repository. They are triggered by events (like pushing code) and can perform tasks like building, testing, and deploying your applications.

**Actions** are the individual steps within a workflow. GitHub provides a wide variety of pre-built actions, or you can create custom actions to perform specific tasks. For example:

- Building your Flutter project.
- Signing and packaging your application.
- Deploying the app to Play Store or TestFlight.

Workflows are defined in YAML files located in the `.github/workflows` directory of your repository. Each workflow file specifies the triggers, jobs, and actions to execute.

---

## Android Setup

### Setting up Keystore and Key Properties

If you haven’t uploaded the app to the Play Store yet, start by following the [official Flutter documentation for building and releasing apps](https://docs.flutter.dev/deployment/android).

You can use a script to generate the keystore and key.properties file:

1. Place the `generate_signature.sh` file in the root of your project folder.
2. Run the script using the terminal command:
   ```sh
   sh generate_signature.sh
   ```

If the script doesn’t have executable permissions, enable it using:

```sh
chmod +x generate_signature.sh
```

The generated files will typically include:

- `key.properties`
- `upload-keystore.jks`

Update your `key.properties` file with the following structure:

```properties
storePassword= <-- your store password -->
keyPassword= <-- your key password -->
keyAlias= <--- key alias --->
storeFile=../upload-keystore.jks
```

### Configuring GitHub Secrets

To use environment variables in your workflows, store them securely in GitHub Secrets. Refer to [Storing Information in GitHub Secrets](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/store-information-in-variables).

Ensure the following secrets are configured:

```yaml
ANDROID_KEYSTORE: ${{ secrets.ANDROID_KEYSTORE }}
ANDROID_KEY_PROPERTIES: ${{ secrets.ANDROID_KEY_PROPERTIES }}
ANDROID_RELEASE_SERVICE_ACCOUNT: ${{ secrets.ANDROID_RELEASE_SERVICE_ACCOUNT }}
```

To deploy to the Play Store, you’ll need a `service-account.json` file:

1. Enable the **Google Play Android Developer API** using this [link](https://console.cloud.google.com/apis/library/androidpublisher.googleapis.com) and click "Enable."
2. Follow [this guide](https://medium.com/@vontonnie/setting-up-a-service-account-on-google-cloud-for-android-app-deployment-c6e16d8fc57b) to create a service account and invite users.

### Uploading to Play Store

To update the "What’s New" section in the Play Store:

1. Create the folder: `distribution/whatsnew/whatsnew.txt`.
2. Add your update information in `whatsnew.txt`.

Replace environment variable placeholders in the following workflow files:

- `deploy_android.yml`
- `release_staging.yml`
- `release_production.yml`

---

## Folder Structure and Workflow Files

Create a `.github` folder at the root of your project directory. Inside this folder, include:

- `workflows`
- `actions`

Place the respective workflow files in these directories. Ensure all configurations are correctly set for deployment.

---

## Updating Workflows

<img width="971" alt="Example Workflow" src="https://github.com/user-attachments/assets/14d59a39-3061-4e24-b13c-9645a6140a33" />

Workflows can be customized to meet specific requirements, such as updating branches, versions, triggering test cases, or using build_runner. Below is an example of a workflow configuration:

### Analyze Workflow Configuration

```yaml
push:
  branches: [dev]

jobs:
  trigger_analysis:
    uses: ./.github/workflows/analyze.yml
    name: Analyze
    with:
      flutter_version: 3.27.0
      java_version: 21
      generate_code_using_build_runner: true
      run_flutter_test: false
```

### Key Modifications:

1. **Branches**:

   - Update the `branches` key to specify which branch triggers the workflow. For example, `[main]` or `[release/*]`.

2. **Flutter and Java Versions**:

   - Modify `flutter_version` and `java_version` to match the versions used in your project.

3. **Trigger Test Cases**:

   - Set `run_flutter_test` to `true` if you want to include test cases during the build process.

4. **Use build_runner**:
   - Set `generate_code_using_build_runner` to `true` to enable code generation during the build.

To apply these changes, edit the workflow file (e.g., `analyze.yml`) in the `.github/workflows` directory and commit the updates to your repository.

---

### Release Staging Workflow Configuration

Similarly, you can update the staging workflow as your requirements. You can update inputs for the job `build_and_release_android` as follows

```yaml
flutter_version: 3.27.0
java_version: 21
bundle_id: com.example.app # the bundle id of the app
track: internal #Deployment track (e.g., `production`, `alpha`, `beta` (Open Testing), `internal` (Internal Testing))
status: completed
whatsnew_file: ./distribution/whatsnew/whatsnew.txt
create_github_release: true # Create apks and upload to Artifacts
upload_to_google_play: true # Create app bundle and upload to Google Play
increment_version: true # Increment versionCode if not tagged
release_type: patch # Change to `major`, `minor`, or `patch`. Defaults to `patch`
flavor: prod # Optional Flavor when building app : (eg. development, staging, production). Comment if not required
generate_code_using_build_runner: true # Use code generation
```

### Release Production Workflow Configuration

<img width="952" alt="Dispatch Workflow Image" src="https://github.com/user-attachments/assets/5816f9e7-9ec2-4a9b-a8c7-bb13a8dcd01d" />

This is similar to the `release_staging.yml` workflow, only key difference is this is a dispatch event which allows you to manually trigger workflows from the GitHub UI.
The workflow_dispatch event allows you to manually trigger workflows with customizable parameters. Here’s an example configuration:

```yaml
workflow_dispatch:
  inputs:
    release_type:
      description: "Select Release Type, eg. patch, minor or major"
      type: choice
      options:
        - patch
        - minor
        - major
      default: minor

    send_for_review:
      description: "Send for review"
      type: boolean
      default: false
```

1. **release_type**:

   - Description: Specifies the type of release (e.g., patch, minor, or major update).
   - Type: Choice with predefined options (patch, minor, major).
   - Default: minor - Used when no option is selected.

2. **send_for_review**:

   - Description: Indicates whether the release should be sent for review.
   - Type: Boolean (true or false).
   - Default: false - If not set, the release is not sent for review.

## IOS Workflow

1. Set up Xcode Cloud using the official [Apple documentation](https://developer.apple.com/documentation/xcode/configuring-your-first-xcode-cloud-workflow/).

2. Inside the `ios` folder, create a directory named `ci_scripts` and place the `ci_post_clone.sh` file inside.

3. If you use environment variables, configure them in Xcode Cloud:

   ![Setting up environment iOS](https://github.com/user-attachments/assets/f64c38e9-3417-4997-a14a-82b4f7430a68)

4. Update your script to include the exact keys from the configured environment variables:

   ```bash
   # Create .env file from environment variables
   cd $CI_PRIMARY_REPOSITORY_PATH
   echo "Generating .env file..."
   cat <<EOF > .env
   HELLO=${HELLO} # set your own environment variables
   EOF
   ```

5. Update your workflow to deploy either to internal testing or directly to the App Store:

   ![Deploy to TestFlight or App Store](https://github.com/user-attachments/assets/4078fac5-91d4-462d-ac46-c46cceaaf2f5)

---

## Additional Resources

- [Flutter Build and Release Documentation](https://docs.flutter.dev/deployment/android)
- [GitHub Actions Documentation](https://docs.github.com/en/actions/writing-workflows)
- [Setting up Google Play API](https://medium.com/@vontonnie/setting-up-a-service-account-on-google-cloud-for-android-app-deployment-c6e16d8fc57b)
- [Upload Android release to the Play Store](https://github.com/r0adkll/upload-google-play?tab=readme-ov-file#readme)
- [Setting up Xcode Cloud](https://developer.apple.com/documentation/xcode/configuring-your-first-xcode-cloud-workflow/)

---

Following this guide will streamline your deployment process, ensuring that your Android and iOS applications are efficiently released and updated. Following the setup may still result in error while uploading the app. Like for example, You may get permission error when uploading the app bundle to the playstore, which is likely due to incorrect service_account.json file. You may also get archive error in iOS if Xcode managed distribution certificate is not set. For more info, please visit developer guidelines or community forums. Someone has likely faced the error you faced and the solution might already be on the internet, you never know. Happy Coding ;)

If any information is incomplete or can be explained or has a proper alternative, please feel free to contact me at [email](ashwin.shrestha2258@gmail.com) | [linkedin](https://www.linkedin.com/in/ashwin-shrestha-264110178/)
