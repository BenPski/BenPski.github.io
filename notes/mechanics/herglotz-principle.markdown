---
title: Herglotz Variational Principle
---

$$
\newcommand{\vary}[1]{\delta(#1)}
\newcommand{\der}[2]{\frac{d#1}{d#2}}
\newcommand{\pder}[2]{\frac{\partial#1}{\partial#2}}  
$$

In many mechanics formalisms it is assumed that the systems being analyzed are conservative and non-conservative phenomena ends up being included later, but what if the systems were assumed non-conservative from the start? Herglotz' Variational Principle is similar to [Hamilton's Principle](hamilton-principle.html) (HP) and shares a similar relationship to the Euler-Lagrange equations except for the ability to have dissipative systems.

Like in HP we being with a Lagrangian for the system $L(q,\dot{q})$ except we modify it to be potentially non-conservative. In order for the system to be non-conservative the Lagrangian must change in time. To introduce this behavior assume a dissipative Lagrangian of the form:
$$
\dot{z} = L(q,\dot{q},z)
$$

Now for the system we are looking for the extremal of the functional $z(q,t)$ instead of the action of the system as in Hamilton's principle. $z$ and the action are very similar. So, we are looking for $\vary{z} = 0$.

First, we take the variation of the differential equation:
$$
\dot{\vary{z}} = \pder{L}{q}\delta q + \pder{L}{\dot{q}}\dot{\delta q} + \pder{L}{z}\vary{z}
$$

Now the solution to this equation for $\vary{z}$ is:
$$
\vary{z}\exp{-\int_0^t \pder{L}{z}ds} = \int (\pder{L}{q}\delta q + \pder{L}{\dot{q}}\dot{\delta q})\exp{-\int_0^t\pder{L}{z}ds}dt
$$

We can use integration by parts and the unperturbed boundary conditions on the right hand side to get:
$$
0 = \vary{z}\exp{-\int \pder{L}{z}dt} = \int \delta q\exp{-\int\pder{L}{z}dt}(\pder{L}{q} - \der{}{t}\pder{L}{\dot{q}} + \pder{L}{z}\pder{L}{\dot{q}})dt
$$

Which since the variation of $q$ must be arbitrary we have:
$$
0 = \pder{L}{q} - \der{}{t}\pder{L}{\dot{q}} + \pder{L}{z}\pder{L}{\dot{q}}
$$
as the generalized Lagrange equations. 

We can see that if $L$ is independent of $z$ then we simply have the original Lagrange equations.



Both the variational principle and the Lagrange equations are extensions of the more typical forms to non-conservative systems.

# Simple Example
It can be difficult to know what the dependence on $z$ should look like, so to go through a simple example we consider a spring-mass-damper system:

$$
m\ddot{q} + b\dot{q} + kq = 0
$$

Since we know the Lagrangian comes from kinetic and potential energy we can guess the form as:

$$
L = \frac{1}{2}m\dot{q}^2 - \frac{1}{2}kq^2 + \alpha z
$$
where $\alpha$ is a coefficient to be determined.

Using the dissipative Lagrange equations we get:

$$
-kq -m\ddot{q} + \alpha m\dot{q} = 0
$$

This should be the same as the original system. This means $\alpha = -\frac{b}{m}$ and the resulting Lagrangian is:

$$
L = \frac{1}{2}m\dot{q}^2 - \frac{1}{2}kq^2 - \frac{b}{m} z
$$
