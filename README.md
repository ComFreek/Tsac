# Tsac

## Purpose

Tsac delivers a litte GUI for adding TypeScript ability to Windows 8 HTML/JS apps.

## How to use

### Preparation (do this once)
1. Setup PowerShell Execution Policy
 
    1. Start PowerShell with administrator privileges. You can use Windows File Explorer: *File (menu) --> Open Windows PowerShell --> [...] as an administrator*.

    2. Type and run this command: `Set-ExecutionPolicy Unrestricted`.

2. Download/Update Tsac

    1. Download Tsac either via Git or as [ZIP](https://github.com/ComFreek/Tsac/archive/master.zip).
    
    2. Execute *install.ps1* (via context menu). It's recommended that you start it via an already opened PowerShell console with administrator privileges!
       <br /><br />
       The script will download the TypeScript Git repository and extract the declration files *winjs.d.ts* and *winrt.d.ts* into the official TypeScript VS extension folder.

### Convert project

1. **BACKUP** the complete folder of your app!

2. Run *gui.ps1* via the context menu (*right-click --> Run with PowerShell*).
   <br />
   (Tip: create a shortcut for quick access!)
   <br /><br />
   ![Screenshot](http://i.imgur.com/D9cJj.png)

   **HINTS:**
   1. Don't select your solution file (`*`.sln), select your ***.jsproj** file!
      <br />
      If you want to reselect a JS file or if you want to convert another project, **restart** the application. It's a known bug that it can't handle such a situation!

   2. Be sure to activate the ***Is this the first time [...]* checkbox** if you're initially converting the project.


## Author
Follow me on Twitter: [@ComFreek](http://twitter.com/ComFreek)
<br />
<br />
You may also like TSCompiler: compile your TypeScript files using JavaScript or PHP on-the-fly: <http://github.com/ComFreek/TSCompiler>
<br />
Other GitHub project: <http://github.com/ComFreek/>

## License
All files are licensed under MIT license: <https://raw.github.com/ComFreek/Tsac/master/LICENSE>
<br />
© 2012 by ComFreek and all other contributors.

The converted project files are **NOT affected** by the license.