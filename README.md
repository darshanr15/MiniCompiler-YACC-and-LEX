# MiniCompiler - YACC and LEX

A simple compiler project demonstrating lexical analysis and syntax parsing using YACC (Yet Another Compiler Compiler) and LEX (Lexical Analyzer). The project includes two key files:

- `minicompiler.l`: Lexical analysis rules (LEX).
- `minicompiler.y`: Syntax and grammar rules (YACC).

## Features
- Lexical analysis with LEX
- Syntax parsing with YACC
- A basic example of a custom programming language compiler

## Prerequisites
- [YACC](https://en.wikipedia.org/wiki/Yacc) (or Bison)
- [LEX](https://en.wikipedia.org/wiki/Lex_(tool))
- A Unix-based OS (Linux/macOS)

## How to Run

Follow these steps to run your mini-compiler on Linux or Windows.

### 1. Install Required Tools

#### For Linux (Ubuntu/Debian-based systems):

- Update your package list:

  ```bash
  sudo apt-get update
  
- Install Bison, Flex, and GCC:

  ```bash
  sudo apt-get install bison flex gcc

Bison is the GNU version of Yacc.
Flex is a tool for generating lexical analyzers (lexical scanning).
GCC is the GNU Compiler Collection used for compiling C code.

#### For Windows (Using MSYS2 or Cygwin):

Option 1: MSYS2 (Recommended)

Download and Install MSYS2 from the official website.

After installation, open the MSYS2 terminal.

- Install Bison, Flex, and GCC by running the following command in the MSYS2 terminal:

  ```bash
  pacman -S mingw-w64-x86_64-bison mingw-w64-x86_64-flex mingw-w64-x86_64-gcc

Option 2: Cygwin

Download and Install Cygwin from Cygwin's official website.
During installation, select Bison, Flex, and GCC packages.
After installation, open the Cygwin terminal.

### 2. Prepare Your Files

Make sure you have the following files in your working directory:

- `minicompiler.l` (Lex file for lexical analysis)

- `minicompiler.y` (Yacc/Bison file for parsing)

### 3. Generate C Code from the `.l` and `.y` Files

Now that the necessary tools are installed, follow these steps to generate the required C files:

#### Step 1: Generate the Lexical Analyzer Code

- In your terminal (whether on Linux or Windows), run:

  ```bash
  flex mini.l

This will generate a file called lex.yy.c.

#### Step 2: Generate the Parser Code

- Run the following command to generate the parser code:

  ```bash
  bison -d mini.y

This will generate:

y.tab.c (C code for the parser)
y.tab.h (Header file for the parser)

#### Step 3: Compile the Generated Code

- Once you have the lex.yy.c and y.tab.c files, compile them using GCC:

  ```bash
  gcc -o minicompiler lex.yy.c y.tab.c

This command:
Compiles the Lex and Yacc generated C files.
(Optionally) Links the Lex library (-ll) and the Yacc library (-ly).
Generates an executable file named minicompiler.

### 4. Run the Compiler

After successful compilation, you can now run the minicompiler.

- Use the following command to run the compiler:

  ```bash
  ./minicompiler

Make sure you have an input file (e.g., input.c or input.txt) with source code to compile.

