---
title: "Lambda Calculus: Simple Interpretation"
prev: 2_simple
---

Now with a simple definition for the lambda calculus and a way to traverse the expression tree we can work on evaluating the expression tree. Since the goal is to make `bagl` a lazy language that is what we'll try to do. One way to do this is to evaluate expressions to weak-head normal form (whnf)