---
title: Geometric Algebra
---

Geometric algebra, or Clifford algebra, is pretty fricken neat-o or at least I'd like to think it is.

One of the main claims is that it is a coordinate-free representation of geometric objects, but I don't quite get the importance at this point.

The main thing thing revolves around the geometric product which I think looks like the most natural extension of the familiar scalar product.

Consider we have 2 collections of different dimensional objects (0, 1, 2, etc.) `a + b` and `x + y`. Now we multiply them, whatever that means. If it looks like scalar multiplication it would result in:

```
ax + ay + bx + by
``` 

Doing the multiplication in  the opposite order we have

```
xa + ya + xb + yb
```

Now in the scalar product we have commutivity, but with higher dimensional objects lets just assume that doesn't make sense for now. This means we have $ab \neq ba$. We can get a little bit further by considering that the product can be split into a symmetric and antisymmetric part.

$$
ab = a\dot b + a\wedge b
$$

which we can rearrange to get

$$
a\dot b = \frac{1}{2}(ab + ba)
$$
$$
a \wedge b = \frac{1}{2}(ab - ba)
$$

What do these mean? Hopefully someday that will be revealed.

Well what happens when we consider the same geometric object in this multiplication? Well it is obvious for the anti-commuting part we have:
$$
a \wedge a = - a \wedge a = 0
$$

I think this is where I have technically diverged from the typically definition as the inner product for arbitrary multivectors is not symmetric just reducing, so it may have been more appropriate to just 