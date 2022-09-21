# hello-world-java

This is the simple *"Hello, World!"* project to build Java application using only `java` and `jar` utilities.

This might be useful to start some mini-project simply by ~~setting up Maven or Gradle~~ writing code 🤗

## Build options

1. Simply build the JAR executable, if there's no previous build:

    ```PowerShell
    .\build.ps1
    ```

2. Build, but clean the previous build:

    ```PowerShell
    .\build.ps1 -Clean
    ```

3. Build and run the project:

    ```PowerShell
    .\build.ps1 -Run
    ```

4. Both clean and run options:

    ```PowerShell
    .\build.ps1 -Run -Clean
    ```

## Example output

```PowerShell
PS> .\build.ps1 -Run
Project is alread built. Skipping build.
Running the project...

#######################################################
Hello, World!
#######################################################

Done.
```
