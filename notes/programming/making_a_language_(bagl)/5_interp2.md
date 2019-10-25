---
title: "Lambda Calculus: Lazy Evaluation"
prev: 4_debruijn
---

Previously the described evaluation actually has a few issues. Some cases do not properly evaluate (e.g., and true false results in true) and some evaluations result in infinite recursion. To fix this I'll take a look at being more detailed in how evaluation works. The main components of evaluating to WHNF are: finding the outermost redex, accumulating arguments, and substitution.

Finding the outermost redex is simply following the left sides of the `Apply`'s until another type of node is reached. When written down on paper this redex corresponds to the frontmost term and is therefore the only thing that needs to be looked at for further evaluation. This can be done with:

```python
class OutermostRedex(ExprDBVisitor):
    """
    Find the expression that constitutes the outermost redex
    essentially traverse all left sides of applies
    """

    def visitApply(self, elem):
        return self(elem.left)

    def visitIndex(self, elem):
        return elem  # really shouldn't be happening

    def visitLambda(self, elem):
        return elem

    def visitSubs(self, elem):
        return elem  # shouldn't ever encounter

    def visitVariable(self, elem):
        return elem
```

For accumulating arguments what we want to do is maintain a stack of the right side terms of the `Apply`'s that were descended past when looking for the outermost redex. A stack in python can be done simply with a list using the `append` and `pop` methods. This can be done with:

```python
class AccumArguments(ExprDBVisitor):
    """
    Accumulates the arguments that are applied to the outermost redex
    """

    def __init__(self):
        self.args = []

    def visitVariable(self, elem):
        return self.args

    def visitSubs(self, elem):
        return self.args

    def visitLambda(self, elem):
        return self.args

    def visitIndex(self, elem):
        return self.args

    def visitApply(self, elem):
        self.args.append(elem.right)
        return self(elem.left)
```


Now the final part is the evaluation/substitution. Essentially if the outermost redex can take arguments and there are enough arguments then the form can be reduced otherwise it is in WHNF. The issue with the previous implementation was that if we were to run into a variable applied to something it would recurse forever, but since a variable can't be applied it should be considered WHNF and terminate. The other issue was substitution could overwrite other substitutions making the evaluation order incorrect in some cases. If we combine all these components into a single object we have:

```python
class Eval(ExprDBVisitor):
    """
    Track to outer redex, maintain stack of arguments, evaluate

    If arriving at something that cannot be evaluated unwind the applies
    """

    def __init__(self):
        self.args = []

    def unwrap(self, elem):
        while len(self.args) > 0:
            elem = ApplyDB(elem, self.args.pop())
        return elem

    def visitVariable(self, elem):
        return self.unwrap(elem)

    def visitSubs(self, elem):
        if isinstance(elem.expr, IndexDB):
            if elem.expr.n == elem.index.n:
                return self(elem.val)
            else:
                return self(elem.expr)
        elif isinstance(elem.expr, LambdaDB):
            return self(LambdaDB(self(SubsDB(elem.expr.body, IndexDB(elem.index.n + 1), elem.val))))
        elif isinstance(elem.expr, ApplyDB):
            return ApplyDB(self(SubsDB(elem.expr.left, elem.index, elem.val)),
                           self(SubsDB(elem.expr.right, elem.index, elem.val)))
        elif isinstance(elem.expr, SubsDB):
            return SubsDB(self(elem.expr), elem.index, elem.val)
        else:
            return self(elem.expr)

    def visitLambda(self, elem):
        if len(self.args) >= 1:
            arg = self.args.pop()
            return self(SubsDB(elem.body, IndexDB(1), arg))
        else:
            return elem

    def visitIndex(self, elem):
        return elem

    def visitApply(self, elem):
        if isinstance(elem.left, VariableDB):
            return self.unwrap(elem)
        else:
            next = Eval()
            next.args.append(elem.right)
            return self(next(elem.left))
```

A few key points are: special case for variables (seems inelegant, but it works), creating new `Eval`'s when going into inner `Apply` to have a new environement, and checking the number of arguments available. Checking the number of arguments isn't too necessary yet, but it will be important when builtins are defined, having the special case for variables is really only useful for having symbol terms as in a real program there are no free variables to deal with, and substitution will likely be done differently later rather than represented as a node.