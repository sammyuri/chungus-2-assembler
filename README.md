# CHUNGUS 2 Assembler

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/FDiapbD0Xfg" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

The CHUNGUS 2 Assembler compiles assembly files into importable data
for the CHUNGUS 2 Minecraft computer.

## Setup

Python and pip are required to run the assembler. 
Head to the [Python Downloads](https://www.python.org/downloads/) page
to install the correct python for your system.

Install the required dependencies at the root of the repository using
a terminal emulator (eg, Terminal in macOS, PowerShell in Windows).

```bash
> pip install -r requirements.txt
```

## Running

Run the following from the root of the repository.

```bash
python assembler.py
```

This will show the following output:

```
Enter a file path: 
```

You must enter a path relative to your current directory.
To use the `breakout` game as an example, type the following:

```
Enter a file path: saves/breakout.s
```

The result will be a new file added in the same directory
with the name `breakout_CHUNGUS2.schem`.
For general usage, passing in `path\to\<assembly>.s` will
generate `path\to\<assembly>_CHUNGUS.schem`.

##  Importing into Minecraft

TODO