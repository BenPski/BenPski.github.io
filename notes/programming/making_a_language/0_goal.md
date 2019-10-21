---
title: "Making a Language: Goal"
next: 1_intro
---

Making your own programing language is an interesting endeavor for understanding how the languages you use work. In the end it won't be anything too special or useful most of the time, but that doesn't matter.

Taking some inspiration from [Crafting Interpreters](https://craftinginterpreters.com/) (CI) and [The Implementation of Functional Programming Languages](https://www.microsoft.com/en-us/research/publication/the-implementation-of-functional-programming-languages/) (IFPL) I'd like to try implementing a lazy functional language. The reason for a lazy functional language is because I like Haskell and think it is interesting, but it is also different enough from CI that it won't just be copying and it probably won't end up too close to what is in IFPL that differences in algorithms will have to be made. I think this is probably the best way to learn things, do something similar, but do not copy. Gets you a bit more engaged, thinking about, and practicing concepts a bit more. In the end though it is still just for learning and trying stuff out.

The main goal is implementing a lazy language and everything else is minor choices and details. However, from the start it looks like I'd only do an interpreter and not a compiler, probably wouldn't have a type system at least at first, and don't care too much about performance. Likely this will have several different approaches tried out and they all won't be fleshed out or completed. The main things that can be said beforehand are:

* Keep it lazy
* Focus on functional programming and lambda calculus
* Do it in rust

Not so sure about the last one considering how little rust I currently know, but it is where I'm starting. 