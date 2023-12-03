# Terminal Tabs Environment

Script to launch multiple Windows Terminal tabs based on a config.

For an example of how to create your own repo to share with your team, see [https://github.com/oatsoda/TerminalTabsEnvironment-Example](https://github.com/oatsoda/TerminalTabsEnvironment-Example)

## Pre-requisites

Ensure you have [Windows Terminal](https://aka.ms/terminal) installed.

## Instructions

1. Create a new repo for sharing your Development Environment with your team.
2. Create a config.json file in the repo defining the tabs and what you want auto-executed in them (execution optional)
3. (Optionally) create a PreScript.ps1 to execute any standard startup executions.
4. Add a .gitignore file containing:

```
config-additions.json
PreScript-Additions.ps1
```

5. Add the TerminalTabsEnvironment submodule with

```
git clone https://github.com/oatsoda/TerminalTabsEnvironment.git
```

Your team members then clone this repo alongside other code repos you have:

```
├── BasePath
│ ├── Repo1
│ ├── Repo2
│ ├── DeveloperEnvironment (or whatever you called your repo)
│ │ ├── config.json
│ │ ├── PreScript.ps1
│ │ ├── .gitignore
```

They then:

1. Create a .bat file to execute:

> {path-to-BasePath}\DeveloperEnvironment\TerminalTabsEnvironment\StartEnvironment.ps1 -ConfigFolderPath {path-to-BasePath}\DeveloperEnvironment -BaseTabPath {path-to-BasePath}

2. (Optionally) create a `config-additions.json` to configure additional tabs for their own purposes.
3. (Optionally) create a `PreScript-Additions.ps1` to configure additional startup executions.

For an example of how to create your own repo to share with your team, see [https://github.com/oatsoda/TerminalTabsEnvironment-Example](https://github.com/oatsoda/TerminalTabsEnvironment-Example)

## Config format

Example:

```json
{
  "prompt": false,
  "focusTab": 2,
  "tabs": [
    {
      "title": "Repo 1",
      "directory": "repo1",
      "isRelative": true,
      "command": ""
    },

    {
      "title": "Repo 2",
      "directory": "repo2",
      "isRelative": true,
      "command": ""
    }
  ]
}
```

## Config options

- `prompt` - Whether you want to be prompted before opening tabs.
- `tabFocus` - Which of the tabs you want to be focused after they are all opened.

- `title` - The title of each tab.
- `directory` - The folder with which to open the tab.
- `isRelative` - Whether the `directory` value is absolute or relative to the provided `BaseTabPath`
- `command` - The command to execute initially on opening the tab. Leave blank to have the tab just open a command prompt in the directory.

## Additional Tabs config

A common scenario is that teams would define a `config.json` in a repo to share this between all team members. However, you team members may want to add their own tabs but without having to edit the `config.json` committed to source to avoid undoing changes when pulling any changes to this repo.

To avoid this, you can specify a `config-additions.json` file to append more tabs to the config. You will want to add this to a `.gitignore` file to avoid any being committed to source.

## Pre Script

To allow ad-hoc executions to take place outside of individual tabs - to initialise environments or run any non-blocking tasks. To do this, create a powershell script
`PreScript.ps1` alongside your `config.json`

Similar to the additional tabs config, you can optionally also create a `PreScript-Additions.ps1` to allow users to add their own executions. Again, you will want to add this to a `.gitignore` of your config repo.

## Execution arguments (for within the script)

- `ConfigFolderPath` - The directory which contains your JSON config file (and any additional config/scripts - see below).
- `BaseTabPath` - The base path for your tabs; allows relative paths to be used.
- `WindowsTerminalProfileName` - The windows terminal profile to use for the tabs.
