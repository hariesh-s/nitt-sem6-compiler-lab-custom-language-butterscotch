# Introduction
We used YACC and LEX to create the frontend of our very own language "ButterScotch".
This project was built as a part of our compiler design lab exercises.
It includes the following features: 
- lexical analysis (tokenizing)
- syntax analysis (parsing)
- syntax tree generation
- intermediate code generation
- basis blocks detection
- code optimization (strength reduction)

# Usage
1. Clone the repo in your local machine
2. Run the following commands:
- yacc -v -d parser.y
- lex lex.l
- cc y.tab.c lex.yy.c
- ./a.out < main.bs

# Reference 
We could not have completed our assignment without the help of another [github repo](https://github.com/AnjaneyaTripathi/c-compiler).
If you want a step by step approach, I suggest you refer above mentioned repo and also follow [his article](https://medium.com/codex/building-a-c-compiler-using-lex-and-yacc-446262056aaa).
