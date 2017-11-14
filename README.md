# MiniCCompiler
Simplified version of C language to MIPS Compiler
 
# Getting Started
Make sure you have installed the dependencies:
 - gcc 4.7 or later
 - GNU make 3.81 or later
 - bison 3.0 or later
 - flex 2.6.0 or later

## Building
To build the program from the source code:

`make scanner`

## Running
To generate the asm output from a program file:

`./scanner < inputFile > asmFile.s`

You can run the MIPS code with an emulator like Spim:

`spim -file asmFile.s`

## Example
The following code example is provided inside the file [in](LICENSE).
```
func main() {
	var int n, int z = 0;	
	read n;
	while (z <= n) {
		print z,"*",n,"=",z*n;

		if (z/2*2 == z) {
			print ", ",z," is even\n";
		}
		else {
			print ", ",z," is odd\n";
		}
		z = z+1;
	}
}
```

# License
MiniCCompiler is provided under MIT License. See [LICENSE](LICENSE).
