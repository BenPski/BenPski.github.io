---
title: Hamilton's Principle
---

$$
\newcommand{\vary}[1]{\delta(#1)}
\newcommand{\der}[2]{\frac{d#1}{d#2}}
\newcommand{\pder}[2]{\frac{\partial#1}{\partial#2}}  
$$

# Concept
For mechanics we can state that the dynamic behavior of a system extremizes the action integral.

In other words the behavior of a system can be described in a local way using Newtonian Mechanics where forces and moments throughout the system balance with each other, but the same system can be described in a global way by finding the configuration of the system that minimizes some objective. This is akin to the idea that equilibrium states exist at a minimum potential energy state. For dynamics the objective becomes the action integral or the time integral of the Lagrangian of the system. 

$$
S = \int_0^T L(q, \dot{q}, t) dt
$$
where $S$ is the action, $L$ is the lagrangian, $q$ are generalized coordinates, $\dot{q}$ are the generalized velocities, and $T$ is the time horizon of the problem.

If we think of a generic particle moving through space it can take any trajectory in time, $q(t), but we want to know which one it actually takes. By Hamilton's Principle we say that it is the trajectory that makes $S$ stationary when subject to a variation in the trajectory or that the variation of $S$ at the actual trajectory is 0. This is like finding the minima of a potential, the tangent at the minima is a line with 0 slope and any small variation around the minima looks like moving along a line, except that it generalizes the idea to a curve through time.

To state this mathematically we have:

$$
\vary{S} = 0
$$
where $\vary{}$ stands for the variation of the trajectory.

How do we define the variation? We start with the curve $q(t)$ and define another as the variation $\delta q$ of the curve we can then make the trajectory:
$$
q(t) \rightarrow q(t) + \epsilon\delta q
$$
where $\epsilon$ is a small parameter that controls the amount of variation.

Now, it is important to note that by changing the trajectory we want to still have the same system we are solving. Since, a system is defined by its boundary conditions at $t=0$ and $t=T$ and the Lagrangian for it dynamics. Changing the trajectory doesn't influence the Lagrangian, but we have to make sure that it does not influence the boundary conditions. To do this define $\delta q$ such that $\delta q(0) = \delta q(T) = 0$ which prevents the considered variation from influencing the boundary conditions. 

With the variation this leaves our action integral as:
$$
S(q+\epsilon\delta q) = \int_0^T L(q+\epsilon\delta q, \dot{q} + \epsilon\dot{\delta q}, t) dt
$$
where we include the time derivative of the variation in $\delta q$ into the perturbation of the velocity. 

If we want to find the stationary point we need to determine the limit of the action integral as $\epsilon$ goes to 0 and set that equal to 0 to find the extremizing trajectory.

$$
\lim_{\epsilon \to 0} S(q + \epsilon \delta q) = 0
$$

We can state this as the derivative evaluated at $\epsilon=0$:
$$
\der{}{\epsilon} \int_0^T L(q+\epsilon\delta q, \dot{q}+\epsilon\dot{\delta q},t) dt \rvert_{\epsilon = 0}
$$

Evaluating the derivative results in a couple applications of the chain rule to the Lagrangian and we get:
$$
\int_0^T \pder{L}{q}\delta q + \pder{L}{\dot{q})\dot{\delta q} dt = 0
$$

Using integration by parts we can convert $\dot{\delta q}$ to $\delta q$ to get a single variation.

$$
\pder{L}{\dot{q}}\delta q \rvert_0^T + \int_0^T \delta q (\pder{L}{q} - \der{}{t}\pder{L}{\dot{q}}) dt = 0
$$

Since we made sure the variation is 0 at the boundaries we know that:

$$
int_0^T \delta q (\pder{L}{q} - \der{}{t}\pder{L}{\dot{q}}) dt = 0
$$

Which is the weak form of the Lagrangian mechanics. If we consider that the variation must be arbitrary then we know that:

$$
\pder{L}{q} - \der{}{t}\pder{L}{\dot{q}} = 0
$$
which is the standard Largrangian mechanics equation.

It is worth noting that this only applies to conservative systems, we can extend it to include non-conservative terms as well later.

## Example

A basic and uninteresting example for this is a particle being thrown through the air and subject to gravity. 

The Lagrangian for this system is $L = T-U$ where $T$ is the kinetic energy and $U$ is the potential energy. The kinetic energy and potential energy for a particle are:
$$
\begin{split}
T = \frac{1}{2} m \dot{q}^T\dot{q} \\
U = mq^Tg
\end{split}
$$
where $q$ is the position vector for the particle in the global frame, $m$ is the mass, and $g$ is the gravitational acceleration vector. 

Hamilton's Principle is then:
$$
\vary{\int_0^T (\frac{1}{2} m \dot{q}^T\dot{q} - m q^Tg)dt} = 0
$$

Evaluating this we can get the weak form of the dynamics as:
$$
\int_0^T \delta q^T(m\ddot{q} + mg) dt = 0
$$

or as expected:
$$ \ddot{q} = -g $$

# Extensions

Given that Hamilton's Principle essentially just gives Lagrangian mechanics what is its benefit and can it be extended in the same way? Later the uses will come into play. Here are some extensions.

## Non-Conservative Loads

In order to include non-conservative loads the simplest method is using Virtual Work or D'Alembert's Principle. Now, the simple way to do this is to just define the riginal action integral as:
$$
S = \int_0^T L+W dt
$$
where $W$ is the work due to the non-conservative forces. Then when evaluating the variations you just have to be careful to only vary the displacements multiplying the loads and not any part of the loads.

However, this can lead to some confusion as we could have $W = qF(q)$ where $F$ is the load and we need to make sure not to vary the $q$ in the definition of $F$ as Virtual Work perturbs the displacements and keeps loads constant. To make sure that this isn't an issue the work can be included in a later portion of the derivation to give what is sometimes known as the Lagrange-D'Alembert principle.
$$
\vary{\int_0^T L dt} = \int_0^T \delta q F dt
$$
where $F$ is the generalized load.

The result will be:
$$
\der{}{t} \pder{L}{\dot{q}} - \pder{L}{q} = F
$$

## Constraints

Similar to Lagrange problems we can introduce contraints with Lagrange multipliers.

If we have $g(q) = 0$ as the contraints on the system we can restate Hamilton's Principle as:
$$
\vary{\int_0^T L(q,\dot{q}) + \lambda g(q) dt} = 0
$$
where $\lambda$ are the Lagrange multipliers. 

The variation gives:
$$
\der{}{t}\pder{L}{\dot{q}} - \pder{L}{q} + \lambda\pder{g}{q} = 0
$$
with the contraints $g(q)$ this is a fully constrained system.

# Applications

Hamilton's Principle here only seems to be a minor generalization of Lagrangian mechanics; however, it has more uses than that. Hamilton's principle generalizes well to other types of mechanics, for example in field theories we define Lagrangian densities and write:
$$
\vary{\int_0^T \int_V L dV dt} = 0
$$
where $L$ is defined as a density over some volume, which is useful in continuum mechanics. There are other extensions to things like Quantum Mechanics.

Another interesting application of Hamilton's Principle is in the derivation of variational integrators. Variational integrators develop numerical schemes from discretized versions of Hamilton's Principle and they have the unique consequence that they are symplectic integrators (they conserve the energy).

Also, due to Hamilton's Principle being an optimization problem it works together with other concepts of optrimization like in Control Theory,