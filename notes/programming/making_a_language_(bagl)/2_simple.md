---
title: "Lambda Calculus: First Implementation"
prev: 1_intro
next: 3_interp
---

In the last section I started looking at lambda calculus, now I'd like to start implementing and playing with it. This will be a just the basics of lambda calculus.

Writing simple lambda calculus in `haskell` notation looks like:
```haskell
data Expr = Variable String
          | Lambda Expr
          | Apply Expr Expr
```

For `rust` the structure has a bit more control over how pointers are handled and can work with mutable and immutable structures safely.

Given that I'd like to make some progress in the language and that I'm still not too comfortable with `rust` to make decent progress, I'm going to be implementing the first version of the language in python because I find it easier to prototype and test with. Also, from here forward the language will be known as `bagl` for "Ben's Awesomely Good Language".

# Lambda Calculus: Python

To model an expression first I'll lay out the structure similarly to the haskell definition:

```python
lass Expr():
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


class Lambda(Expr):
    """
    Lambda abstraction
    """

    def __init__(self, head, body):
        self.head = head
        self.body = body

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
```

This works as a first implementation, but their will be a few inconvenient things about it. The most annoying problem will be having to define functions that traverse over the expression tree as that can be a bit tedious for objects relative to functional programming languages, this can be handled using the *visitor pattern*. For the visitor pattern what happens is the data structure (e.g., the expression object tree) defines a method called `accept` that takes a visitor calls the appropriate visitor method on itself, the visitor then defines the relevant methods to operate on the individual components of the data structure. This makes it a lot like a functor definition in haskell. One issue is that this is quite tedious and a lot of boilerplate to write as the different kinds of nodes in the expression tree grows, but this can be handled with some scripting/metaprogramming. The visitor pattern for `Expr` is defined as follows:

```python
class ExprVisitor():
    """
    Visitor definition for the expression tree
    """
    __metaclass__ = ABCMeta

    def __call__(self, expr):
        return expr.accept(self)

    @abstractmethod
    def visitVariable(self, elem):
        pass

    @abstractmethod
    def visitLambda(self, elem):
        pass

    @abstractmethod
    def visitApply(self, elem):
        pass
```      

The visitor will allow us to recursively call operations defined by `self` easily over the expression tree. Note that `__call__` has been defined for convenience of recursive calls, so rather than writing `elem.accept(self)` everywhere we write `self(elem)`. 

To get a view of how the visitor pattern works lets take a look at a simple printer for the expressions. For this variables just display their string, lambdas display a $\lambda$ (or just \\) in this case, and apply juxtaposes its values.

```python
class ExprPrint(ExprVisitor):
    def visitVariable(self, elem):
        return elem.s

    def visitLambda(self, elem):
        return "(\\" + self(elem.head) + "." + self(elem.body) + ")"

    def visitApply(self, elem):
        return self(elem.left) + " " + self(elem.right)
```

Which can be called as:

```python
x = Variable("x")
y = Variable("y")
id = Lambda(x, x)
expr = Apply(id,y)
printer = ExprPrint()
print(printer(expr))
```
to get: `(\x.x) y` as expected.

So, now lambda functions can be written and next we can start to interpret or evaluate lambda expressions.