# Add a new function to d365fo.tools

When adding a new function to d365fo.tools, there are a couple of things to consider.

## Function name

The function name should be descriptive and follow the naming convention of the project. The function name should be in the format `Verb-Noun`. For example, `Get-D365Module`.

This is based on the general recommendation for PowerShell function names.
For the `Verb` part, use one of the [approved verbs for PowerShell commands](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands).

For the `Noun` part, always start it with the prefix `D365`. This acts kind of like a namespace for all the functions provided by the d365fo.tools PowerShell module. It makes it easier to differentiate them from other PowerShell functions.

The the rest of the `Noun` part should be descriptive of what the function does. Take a look at some of the existing functions for inspiration:
- [Get-D365Environment](Get-D365Environment.md)
- [Import-D365AadUser](Import-D365AadUser.md)
- [Invoke-D365ModuleFullCompile](Invoke-D365ModuleFullCompile.md)

The last example is an example if there are no verbs in the allowed list of verbs that fits the function. In that case, use `Invoke` as the verb and then describe what the function does in the `Noun` part.

## Function template

If you are new to PowerShell functions, [Functions](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/09-functions) is a good place to learn about the building blocks for them. d365fo.tools uses advanced functions, which is a way to create functions that are more powerful and flexible. While there is no specific template for the functions in d365fo.tools, most editors that support PowerShell will have snippets that can help you create a new function. Other existing functions are also a good place to look at.

## Add the function to the module

When you have created the function, you need to add it to the module. The module is defined by a module manifest file. This file is located in the `d365fo.tools` folder and is named `d365fo.tools.psd1`. Among other things, this file contains a list of all the functions in the module. You need to add your new function to this list.

To do so, look for the line in the file that starts with `FunctionsToExport = @(`. This is an array of all the functions in the module. Add your new function to this list. Make sure to follow the syntax of the other functions in the list.