---
title: "Lambda Calculus: Converting to De Bruijn Notation"
prev: 3_interp
---

As mentioned early on in the discussion of lambda calculus I talked about De Bruijn notation (DBN). This is a way of getting rid of any naming collisions with variables, but it is more difficult to write. This motivates writing regular lambda calculus and then convert to DBN before evaluating the expression. 

To convert to DBN we define a new expression type that includes an index node as well as the already existing nodes and the head of the lambda abstractions no longer exists. The new expression type is:

```python
class ExprDB():
    """
    The expression tree object for lambda calculus in de bruijn form
    """
    __metaclass__ = ABCMeta

    @abstractmethod
    def accept(self, visitor):
        pass


class VariableDB(ExprDB):
    """
    Holds a name for a symbol
    """

    def __init__(self, s):
        self.s = s

    def accept(self, visitor):
        return visitor.visitVariable(self)


class IndexDB(ExprDB):
    """
    Index in de bruijn notation
    """

    def __init__(self, n):
        self.n = n

    def accept(self, visitor):
        return visitor.visitIndex(self)


class LambdaDB(ExprDB):
    """
    Lambda abstraction
    """

    def __init__(self, body):
        self.body = body

    def accept(self, visitor):
        return visitor.visitLambda(self)


class ApplyDB(ExprDB):
    """
    Function application
    """

    def __init__(self, left, right):
        self.left = left
        self.right = right

    def accept(self, visitor):
        return visitor.visitApply(self)


class SubsDB(ExprDB):
    """
    A substitution node
    [E:x\y]
    """

    def __init__(self, expr, index, val):
        self.expr = expr
        self.index = index
        self.val = val

    def accept(self, visitor):
        return visitor.visitSubs(self)
```

Then, we have a visitor pattern as well:

```python
class ExprDBVisitor():
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
    def visitIndex(self, elem):
        pass

    @abstractmethod
    def visitLambda(self, elem):
        pass

    @abstractmethod
    def visitApply(self, elem):
        pass

    @abstractmethod
    def visitSubs(self, elem):
        pass
```

Now the printing is essentially the same, but the evaluation changes a bit due to how substitution will now work. To see how the substitution changes we first want to see how we convert to DBN. 

For DBN the location for an expression to be substituted into is marked by an index which indicates which lambda abstraction it belongs to. Essentially the index marks the depth of the expression away from its associated lambda abstraction for example as was shown in the [introduction](1_intro). That means to replace a variable with an index we have to track when a head argument shows up and how deep we have gone into a lambda abstraction for substitution. We do this by:

```python
class ExprToExprDB(ExprVisitor):
    """
    Convert regular lambda calculus expressions to de bruijn notation

    have to keep track of associated indices for variables so modify some internal state

    just using a dictionary :: variable -> index
    update indices when going down one level in a lambda
    assume no shadowing of names
    if variable not found just leave it as an atom

    when encountering a lambda have to initialize a new index in the environment
    """

    def __init__(self):
        self.env = {}

    def visitVariable(self, elem):
        if elem.s in self.env:
            return IndexDB(self.env[elem.s])
        else:
            return VariableDB(elem.s)

    def visitLambda(self, elem):
        s = elem.head.s
        self.env[s] = 0
        for key in self.env.keys():
            self.env[key] += 1
        return LambdaDB(self(elem.body))

    def visitApply(self, elem):
        self_copy = copy.deepcopy(self)
        return ApplyDB(self_copy(elem.left), self_copy(elem.right))

    def visitSubs(self, elem):
        self_copy = copy.deepcopy(self)
        return SubsDB(self_copy(elem.expr), self_copy(elem.var), self_copy(elem.val))
```

With this we use an environment dictionary to keep track of what the variables are and what index they belong to. The deepcopies are for the sake of having the correct environment being passed along (it would get written to outside the relevant scope). Now the interpretation will work the same way as before, but instead of tracking variables we track indices and their associated depth.

```python
class ExprDBWHNF(ExprDBVisitor):
    """
    Evaluate to weak head normal form

    essentially if an apply can be done it should be done
    Apply(Lambda(blah), value) -> substitute(blah.body, blah.head, value)
    """

    def visitVariable(self, elem):
        return elem

    def visitIndex(self, elem):
        return elem

    def visitLambda(self, elem):
        return elem

    def visitApply(self, elem):
        if isinstance(elem.left, LambdaDB):
            return self(SubsDB(elem.left.body, IndexDB(1), elem.right))
        else:
            return self(ApplyDB(self(elem.left), elem.right))

    def visitSubs(self, elem):
        if isinstance(elem.expr, IndexDB):
            if elem.expr.n == elem.index.n:
                return self(elem.val)
            else:
                return self(elem.expr)
        elif isinstance(elem.expr, LambdaDB):
            return self(LambdaDB(self(SubsDB(elem.expr.body, IndexDB(elem.index.n + 1), elem.val))))
        elif isinstance(elem.expr, ApplyDB):
            return self(ApplyDB(self(SubsDB(elem.expr.left, elem.index, elem.val)),
                                self(SubsDB(elem.expr.right, elem.index, elem.val))))
        return elem.expr
```

With this it is easier to write more complex expressions to evaluate as the names of variables will never have an issue. For a more complex example we can look at logical functions to see how they run.

```python
convert = ExprToExprDB()
    printer = ExprDBPrint()
    interp = ExprDBWHNF()

    x = Variable("x")
    y = Variable("y")
    z = Variable("z")

    t = Lambda(x,Lambda(y,x))
    f = Lambda(x,Lambda(y,y))
    id = Lambda(x,x)
    NOT = Lambda(x, Apply(Apply(x, f), t))
    AND = Lambda(x, Lambda(y, Apply(Apply(x, y), x)))
    OR = Lambda(x, Lambda(y, Apply(Apply(x, x), y)))

    expr1 = convert(Apply(Apply(AND, f), Apply(NOT, t)))
    expr2 = convert(Apply(Apply(OR, t), Apply(NOT, t)))


    print(printer(interp(expr1)))
    print(printer(interp(expr2)))
```

We know that the output should be `expr1 == false == (\x.(\y.y))` and `expr2 == true == (\x.(\y.x))` if we evaluate these we get:

`
(\ (\ #1))
(\ (\ #2))
`

This is a very simple implementation of lambda calculus and there are a few useful functions to have and use on the expression trees. So, in the following sections I'll look at things like having a graph structure, finding the outermost redex, counting arguments, and builtin functions. 