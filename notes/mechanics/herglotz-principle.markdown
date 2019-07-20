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

To get back the typical Lagrangian the system has $\dot{z} = 0$. Now $z$ acts as a measure of the dissipation in the system while still maintaining the regular mechanics. 

So now we can formulate a variational calculus problem like HP with this new $L$. The action integral is then:

$$
S = \int_0^T L(q,\dot{q},z) dt
$$ 
where $T$ is the time horizon and the boundary conditions are known for the system. 

If we were to follow the same steps as HP then we would run into an issue with $z$ because we do not know how to perturb it. However, observing that the derivative of $z$ is dependent on itself, the trajectory, and the trajectory velocity we can conclude that $z$ should be a function purely of the trajectory, $z = z(q)$. With $z$ dependent on $q$ we can do the same as with HP and look for the stationary trajectory by perturbing the path. Also  important to keep in mind that the pertubation can't change the boundary conditions, $\delta q(0) = \delta q(T) = 0$.

$$
S(q+\epsilon\delta q, \dot{q} + \epsilon\dot{\delta q}) = \int_0^T L(q+\epsilon\delta q, \dot{q}+\epsilon\dot{\delta q}, z(q+\epsilon\delta q))dt
$$

Evaluating the first variation we have:

$$
0 = \int_0^T (\pder{L}{q}\delta q + \pder{L}{\dot{q}}\dot{\delta q} + \pder{L}{z}\pder{z}{q}\delta q) dt 
$$

We can recognize that $\pder{z}{q} = \pder{\dot{z}}{\dot{q}} = \pder{L}{\dot{q}}$ and use integration by parts to eliminate $\dot{\delta q}$. This rearranges to:

$$
0 = \int_0^T \delta q (\pder{L}{q} - \der{}{t}\pder{L}{\dot{q}} + \pder{L}{z}\pder{L}{\dot{q}})dt
$$

Recognizing that $\delta q$ is arbitrary then we get the modified Euler-Lagrange equations:

$$
\pder{L}{q} - \der{}{t}\pder{L}{\dot{q}} + \pder{L}{z}\pder{L}{\dot{q}} = 0
$$

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
