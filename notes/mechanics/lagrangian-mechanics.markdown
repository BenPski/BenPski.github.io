---
title: Lagrangian Mechanics
---

$$
\newcommand{\der}[2]{\frac{d#1}{d#2}}
\newcommand{\pder}[2]{\frac{\partial#1}{\partial#2}}  
\newcommand{\firstVary}[1]{\der{}{\epsilon} #1 \rvert_{\epsilon=0}}
$$

One of the first systematic approaches to modeling physical systems and one that is commonly built off of for other physics models is Lagrangian mechanics. Now the most common way of deriving Lagrangian mechanics is from [Hamilton's principle](hamilton-principle.html), but considering it was developed prior to Hamilton's principle it motivates a different approach to deriving the equations. However, I don't know one off the top of my head and don't feel like figuring one out, but the equations of motion from Lagrangian mechanics are the same as predicted by Newtonian mechanics and is often easier to use. The drawback is non-conservative forces generally cannot be modelled unless we modify the theory with D'Alembert's principle (The principle of virtual work) to incorporate the non-conservative forces.

Briefly, Hamilton's principle states that the action (time integral of the Lagrangian of a system) is stationary for the dynamic path. Posing this mathematically will give us the Euler-Lagrange equations:
$$
    \der{}{t}\pder{L}{\dot{q}} = \pder{L}{q}
$$
where $L(q,\dot{q},t)$ is the Lagrangian of the system, $q$ are the generalized coordinates of the system, and $\dot{q}$ are the generalized velocities. 

The Lagrangian is a very general function and can be applied to fields outside of physics, but for physical systems it is typically written in terms of the kinetic, $T$, and potential energy, $U$.
$$
    L = T - U
$$

For a particle the kinetic energy is:
$$
    T = \frac{1}{2} m \dot{q}^2
$$

Then assuming $U$ is purely a function of $q$ we can substitute into the Euler-Lagrange equations to get:
$$
    \der{}{t}m\dot{q} = \pder{U}{q}
$$

When $U$ is a conservative force we have $\pder{U}{q} = F$ and we get:
$$
    m\ddot{q} = F
$$

or the classic $F = ma$ from Newtonian mechanics.


There are then several important properties and extensions of the Lagrangian and Lagrangian mechanics to know.

# Non-Uniqueness of the Lagrangian

For a given set of equations of motion there exists infinitely many Lagrangians that can describe the system and therefore the Lagrangian is not unique for the system. There are 3 types of modifications that can be made to a Lagrangian that will give the same equations of motion. The proof of which is easiest when using Hamilton's principle and variational calculus.

## Multiplying by a scalar

For the original system we have:
$$
    S = \int_0^\tau L(q,\dot{q},t) dt
$$

Now if we obtain a new Lagrangian by multiplying by a scalar, $\lambda$, we have:
$$
    S' = \int_0^\tau \lambda L(q, \dot{q},t) dt
$$

Evaluating the variation of both actions we get:
$$
    \delta(S) = \int_0^\tau \delta q (\pder{L}{q} - \der{}{t}\pder{L}{\dot{q}}) dt \\
    \delta(S') = \lambda\int_0^\tau \delta q (\pder{L}{q} - \der{}{t}\pder{L}{\dot{q}}) dt
$$

Given that the variation must be 0 to meet Hamilton's principle we conclude from both equations that:
$$
    \pder{L}{q} - \der{}{t}\pder{L}{\dot{q}} = 0
$$
concluding that both describe the same system.

## Addition of a scalar

Following a similar derivation, if we modify $L$ by adding a constant, $\alpha$, the equations of motion should be the same.

$$
    S' = \int_0^\tau (L(q,\dot{q},t) + \alpha) dt = \int_0^\tau L(q,\dot{q},t)dt + \alpha\tau 
$$

The variation of which again gives the same equations because the second term is 0 when taking the variation.

## Addition of a time derivative

Now the most interesting modification is to add a term like $\der{}{t}F(q,t)$. The new action is:
$$
    S' = \int_0^\tau (L(q,\dot{q},t) + \der{}{t}F(q,t)) dt = \int_0^\tau Ldt + F(q(\tau),\tau) - F(q(0), 0)
$$

If we take the variation of the new action we get:
$$
    \delta(S') = \delta(S) + \delta(F(q(\tau),\tau) - F(q(0), 0))
$$

Then, when we take the variation we have to assure that the boundary conditions do not change meaning $\delta q(0) = \delta q(\tau) = 0$. This makes the rightmost term is always 0 and therefore this modification does not influence the equations of motion.

So modifying a Lagrangian by multiplying by a scalar, adding a scalar, or adding the time derivative of a function of $q$ and $t$ ($\der{}{t}F(q,t)$) does not modify the system of equations and can be seen as equivalent definitions for the system.

# Change Coordinates

In the original statement of Lagrangian mechanics we use generalized coordinates to describe the system, this means we haven't put any restriction on how we describe the system configuration. So, we can ask what happens when we change from the original generalized coordinates to new generalized coordinates? To start we have the original mechanics in terms of the generalized coordinates $q$.

$$
    0 = \pder{L}{q} - \der{}{t}\pder{L}{\dot{q}}
$$

Now lets assume we have some new generalized coordinates:
$$
    Q = Q(q,t)
$$

If we then assume that this mapping is invertible we have:
$$
    q = q(Q,t)
$$

The time derivative is then:
$$
    \dot{q} = \pder{q}{Q}\dot{Q} + \pder{q}{t}
$$

This also gives the relation:
$$
    \pder{\dot{q}}{\dot{Q}} = \pder{q}{Q}
$$

We can write the action as:
$$
    S = \int_0^\tau L(q(Q,t), \pder{q}{Q}\dot{Q}) dt
$$

Thus Hamilton's principle is:
$$
    \delta S = 0 = \der{}{\epsilon} \int_0^\tau L(q(Q+\epsilon \delta Q,t), \pder{q}{Q}(\dot{Q} + \epsilon \delta \dot{Q})) dt |_{\epsilon = 0}
$$

Simplifying gives us:
$$
    0 = \int_0^\tau \pder{L}{q}\pder{q}{Q}\delta Q + \pder{L}{\dot{q}}\pder{p}{Q}\delta\dot{Q} dt
$$

We can substitute out $\pder{q}{Q}$ to get:
$$
    0 = \int_0^\tau \pder{q}{Q} (\pder{L}{q}\delta Q + \pder{L}{\dot{q}} \delta\dot{Q})dt
$$

Using integration by parts and the preservation of the boundary conditions we get:
$$
    0 = \int_0^\tau \delta Q\pder{q}{Q}(\pder{L}{q} - \der{}{t}\pder{L}{\dot{q}}) dt
$$

Which gives us the same equation as before:
$$
    0 = \pder{L}{q} - \der{}{t}\pder{L}{\dot{q}}
$$

Since the variation was taken with respect to $Q$ this implies taking the derivatives with respect to either generalized coordinates will give the same mechanics so either:
\begin{gather}
    0 = \pder{L}{q} - \der{}{t}\pder{L}{\dot{q}} \\
    0 = \pder{L}{Q} - \der{}{t}\pder{L}{\dot{Q}}
\end{gather}

can be used.

# Lagrangian Densities

For systems that are not just simple particles we will have the Lagrangian defined as integrals over space (e.g., solids and fluids) and we will get some new equations. To start, lets look at a simple case where the Lagrangian is an integral over one spatial dimension.

$$
    L = \int \bar{L}(q,\dot{q},\der{q}{s}) ds
$$

Now the generalized coordinates $q$ are defined over every spatial point, $s$, and the Lagrangian density $\bar{L}$ depends on the spatial derivative of $q$ as well. Now using Hamilton's principle we have:

$$
    S = \int_0^\tau\int \bar{L}(q, \dot{q}, \der{q}{s}) ds\,dt
$$ 
as the action and

$$
    \delta S = 0 = \der{}{\epsilon} \int \int \bar{L}(q+\epsilon \delta q, \dot{q} + \epsilon\dot{\delta q}, \der{q}{s} + \epsilon\der{}{s}\delta q) ds\,dt
$$
as the variation of the action.

Simplifying we have:
$$
    0 = \int\int \pder{\bar{L}}{q}\delta q + \pder{\bar{L}{\dot{q}}\dot{\delta q} + \pder{\bar{L}}{\der{q}{s}}\der{\delta q}{s} ds\,dt
$$

Using integration by parts and intechanging the order of integration we get:

$$
    0 = \int_0^\tau (\pder{\bar{L}}{\der{q}{s}\delta q|_{s=0}^{1} + \int_0^1 \delta q (\pder{bar{L}{q} - \der{}{t}\pder{\bar{L}}{\dot{q}} - \der{}{s}\pder{\bar{L}}{\der{q}{s}})ds)dt
$$
where $s\in[0, 1]$ is assumed for the sake of specifying the boundary conditions and that $\delta q(t=0) = \delta q(t=\tau) = 0$.

Now, the variation on the boundary conditions for space depends on the problem. If the boundaries are fixed (e.g., the end is connected to a rigid wall) then the variations at the boundary are 0, but if the boundaries are free we do not have that restriction. In the fixed boundaries case we have:

$$
    0 = \int\int \delta q (\pder{\bar{L}{q}} - \der{}{t}\pder{\bar{L}}{\dot{q} - \der{}{s}\pder{\bar{L}}{\der{q}{s}})ds\,dt
$$ 

It can be easily seen that this implies:
$$
    0 = \pder{\bar{L}{q}} - \der{}{t}\pder{\bar{L}}{\dot{q} - \der{}{s}\pder{\bar{L}}{\der{q}{s}}
$$

or the Euler-Lagrange equations over a one-dimensional field.

For the not fixed case we can say that the term due to the boundary conditions will cancel with the constant of integration and provide the form of the boundary condition equations for the system of partial differential equations and we get the same equation as before, but with boundary conditions:

\begin{gather}
    0 = \pder{\bar{L}{q}} - \der{}{t}\pder{\bar{L}}{\dot{q} - \der{}{s}\pder{\bar{L}}{\der{q}{s}} \\
    \pder{\bar{L}}{\der{q}{s}}(s=0) = a \\
    \pder{\bar{L}}{\der{q}{s}}(s=1) = b \\
\end{gather}
where $a$ and $b$ are the boundary conditions.

Now this idea can be extended to dependence on higher order derivatives and integration which will generally look like:
$$
    0 = \pder{\bar{L}}{q} - \der{}{t}\pder{\bar{L}}{\dot{q}} - \sum_i \frac{d^i}{ds^i} \pder{\bar{L}}{\frac{d^iq}{ds^i}}
$$

