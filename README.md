# Terminal Tabs Environment

Script to launch multiple Windows Terminal tabs based on a config

## Pre-requisites

Ensure you have [Windows Terminal](https://aka.ms/terminal) installed.

## Instructions

1. Clone the repo.
2. Create a config.json file (see sample), preferably not in the cloned folder. See recommendation below
3. Create a .bat file to execute:

> <path-to-cloned-repo>\StartEnvironment.ps1 -ConfigFilePath <path-to-your-config>\config.json -BaseTabPath <path-to-execute-from>

4. Create a shortcut to the .bat file on your desktop for easy daily startup.

## Recommendation

If using this to work with multiple repositories, for simplicity, it's best to structure your folders with each repo alongside, and with your config alongside too:

BasePath

- Repo1
- Repo2
- TTE\config.json

## Example

TerminalTabsEnvironment is cloned to `C:\source\TerminalTabsEnvironment`

My code repos are cloned under `C:\source\myrepos\`, e.g. `C:\source\myrepos\repo1`, `C:\source\myrepos\repo2`

- Create a folder (you might want to actually make this a repo so you can share a basic outline of the config with your team and use relative paths in the config.json)

> c:\source\TTE

- Create a `config.json` in the new folder with the following content:

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

- Create a `start.bat` file in the new folder with the following content:

```
c:\source\TerminalTabsEnvironment\StartEnvironment.ps1 -ConfigFilePath c:\source\myrepos\TTE\config.json -BaseTabPath c:\source\myrepos
```

- Running the `start.bat` will open a new Windows Terminal with two tabs, the first in the `repo1` folder, the second in the `repo2` folder.

Of course, you can execute commands automatically within those folders, e.g. `dotnet run`, `yarn run` etc.

## Execution arguments

`ConfigFilePath` - The location of your JSON config file.
`BaseTabPath` - The base path for your tabs; allows relative paths to be used.
`WindowsTerminalProfileName` - The windows terminal profile to use for the tabs.

## Config options

`prompt` - Whether you want to be prompted before opening tabs.
`tabFocus` - Which of the tabs you want to be focused after they are all opened.

`title` - The title of each tab.
`directory` - The folder with which to open the tab.
`isRelative` - Whether the `directory` value is absolute or relative to the provided `BaseTabPath`
`command` - The command to execute initially on opening the tab. Leave blank to have the tab just open a command prompt in the directory.
