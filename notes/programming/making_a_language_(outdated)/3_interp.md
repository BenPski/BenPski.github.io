---
title: "Lambda Calculus: Simple Interpretation"
prev: 2_simple
next: 4_debruijn
---

For evaluating the definition of the lambda calculus from last section the key idea is substitution. Substitution takes a lambda abstraction applied to another expression and substitutes it for the variable in the head of the abstraction. Essentially we can write something like:

\begin{equation}
    (\lambda x . M) N => [M | x \rightarrow N]
\end{equation}

Which states that in the expression `M` substitute all instances of the variable `x` with expression `N`. TO start we can add a substitution node to represent this idea to make sure it is working as intended.

```python
class Subs(Expr):
    """
    A substitution node
    [E | x -> y]
    """

    def __init__(self, expr, var, val):
        self.expr = expr
        self.var = var
        self.val = val

    def accept(self, visitor):
        return visitor.visitSubs(self)
```

Then we can add the relevant method to `ExprVisitor` and define a printing method.

```python
def visitSubs(self, elem):
    return "[ " + self(elem.expr) + " | " + self(elem.var) + " -> " + self(elem.val) + " ]"
```

To actually make an interpreter to evaluate the lambda expressions we need to implement a new visitor. For a lazy language we can use weak head normal form (WHNF) evaluation to  get the proper evaluation order. To start we just want to see the interpreter change the proper nodes to substitution and we will worry about doing actual substitution later. This leaves us:

```python

class ExprWHNF(ExprVisitor):
    """
    Evaluate to weak head normal form

    essentially if an apply can be done it should be done
    Apply(Lambda(blah), value) -> substitute(blah.body, blah.head, value)
    """

    def visitVariable(self, elem):
        return elem

    def visitLambda(self, elem):
        return elem

    def visitApply(self, elem):
        if isinstance(elem.left, Lambda):
            return self(Subs(elem.left.body, elem.left.head, elem.right))
        else:
            return self(Apply(self(elem.left), elem.right))

    def visitSubs(self, elem):
        return elem
```

So, here we will just replace applications that can be evaluated with the proper substitution and go no further. We can do some simple tests to see this in action.

```python
interp = ExprWHNF()
printer = ExprPrint()
x = Variable("x")
y = Variable("y")
id = Lambda(x,x)
expr = Apply(id,y)
print(printer(interp(expr)))
```

which evaluates to:

`[ x | x -> y ]`

as we should expect. We could try a more complex case, but it isn't terribly interesting as this is a very basic transformation.

Now we move onto actually evaluating a substitution node. For substitution we have a few things that can happen. First, if the expression is the same variable that is being substituted for then we do the substitution by replacing it with the new expression. If we encounter a lambda we simply move the substitution deeper into the body to continue looking for where the new expression should go. If we arrive at an apply node then we carry the substitution farther into both the left and right of the application. Then, if none of those matched we ran into a siuation where there is no substitution to do since everything has been exhausted therefore just give back the original body we were trying to substitute into. All further recursive calls should be handled as well.

```python
def visitSubs(self, elem):
    if isinstance(elem.expr, Variable):
        if elem.expr.s == elem.var.s:
            return self(elem.val)
        else:
            return self(elem.expr)
    elif isinstance(elem.expr, Lambda):
        return self(Lambda(elem.expr.head, self(Subs(elem.expr.body, elem.var, elem.val))))
    elif isinstance(elem.expr, Apply):
        return self(Apply(self(Subs(elem.expr.left, elem.var, elem.val)),
                          self(Subs(elem.expr.right, elem.var, elem.val))))
    return elem.expr
```

Running the previous example we no longer see the substitution node and get:

`(\x.x) y == y`

This all works fine for basic interpretations of lambda calculus; however, trying to write complex expressions becomes an issue due to shadowing of the names. We could make some adjustments to how equality is checked for variables, but it will be easier to convert to De Bruijn notation to eliminate variable names in the first place. This will be done in the next section.


