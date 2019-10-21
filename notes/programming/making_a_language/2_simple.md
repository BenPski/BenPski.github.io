---
title: "Lambda Calculus: First Implementation"
prev: 1_intro
next: 3_interp
---

In the last section started looking at lambda calculus, now want to actually start implementing it and playing with it. Since, it is just a simple implementation it'll be just trying some different data structures and printing.

For lambda calculus with De Bruijn notation the basic definition written in haskell is:
```haskell
data Expr = Index Int
          | Lambda Expr
          | Apply Expr Expr
```

For rust we can decide how to layout the structure with a bit more control. We can use an immutable data structure or can use a mutable structure with pointers. I'm not too comfortable with rust's memory system yet, but I know the basic references are Box, RC, and ARC. 

Given that I'd like to make some progress in the language and that I'm still not too comfortable with rust to make decent progress, I'm going to be implementing the first version of the language in python because I find it easier to prototype and test with. Also, from here forward the language will be known as `bagl` for Ben's Awesomely Good Language.

# Lambda Calculus: Python

To model an expression first I'll lay out the structure similarly to the haskell definition:

```python
class Expr():
    __metaclass__ = ABCMeta

    def __init__(self):
        pass


class Index(Expr):
    def __init__(self, n):
        self.n = n


class Lambda(Expr):
    def __init__(self, expr):
        self.expr = expr


class Apply(Expr):
    def __init__(self, left, right):
        self.left = left
        self.right = right
```

This works as a first implementation, but their will be a few inconvenient things about it. First, there are no variables/symbols for representing values when testing, but this should be easy to add. The most annoying problem will be having to define functions that traverse over the expression tree as that can be a bit tedious for objects relative to functional programming languages, this can be handled using the *visitor pattern*. For the visitor pattern what happens is the data structure (e.g., the expression object tree) defines a method called `accept` that takes a visitor calls the appropriate visitor method on itself, the visitor then defines the relevant methods to operate on the individual components of the data structure. This makes it a lot like a functor definition in haskell. One issue is that this is quite tedious and a lot of boilerplate to write as the different kinds of nodes in the expression tree grows, but this can be handled with some scripting/metaprogramming. The `Expr` definition with variables and the visitor pattern implemented is:

```python
class Expr():
    """
    The expression tree object for lambda calculus
    """
    __metaclass__ = ABCMeta

    @abstractmethod
    def accept(self, visitor):
        pass


class Variable(Expr):
    """
    Holds a name for a symbol
    """

    def __init__(self, s):
        self.s = s

    def accept(self, visitor):
        return visitor.visitVariable(self)


class Index(Expr):
    """
    Index in de bruijn notation
    """

    def __init__(self, n):
        self.n = n

    def accept(self, visitor):
        return visitor.visitIndex(self)


class Lambda(Expr):
    """
    Lambda abstraction
    """

    def __init__(self, expr):
        self.expr = expr

    def accept(self, visitor):
        return visitor.visitLambda(self)


class Apply(Expr):
    """
    Function application
    """

    def __init__(self, left, right):
        self.left = left
        self.right = right

    def accept(self, visitor):
        return visitor.visitApply(self)


class ExprVisitor():
    """
    Visitor definition for the expression tree
    """
    __metaclass__ = ABCMeta

    @abstractmethod
    def visitVariable(self, elem):
        pass

    @abstractmethod
    def visitIndex(self, elem):
        pass

    @abstractmethod
    def visitLambda(self, elem):
        pass

    @abstractmethod
    def visitApply(self, elem):
        pass
```      

To get a view of how the visitor pattern works lets take a look at a simple printer for the expressions. For this variables just display their string, indices show a # and their index, lambdas display a $\lambda$ (or just \\) in this case, and apply juxtaposes its values.

```python
class ExprPrint(ExprVisitor):
    def visitVariable(self, elem):
        return elem.s

    def visitIndex(self, elem):
        return "#" + str(elem.n)

    def visitLambda(self, elem):
        return "(\\ " + elem.expr.accept(self) + ")"

    def visitApply(self, elem):
        return elem.left.accept(self) + " " + elem.right.accept(self)
```

Which can be called as:

```python
id = Lambda(Index(1))
x = Variable("x")
expr = Apply(id,x)
printer = ExprPrint()
print(expr.accept(printer))
```
to get: `(\ #1) x` as expected.

Next, we can move onto interpreting the expressions.