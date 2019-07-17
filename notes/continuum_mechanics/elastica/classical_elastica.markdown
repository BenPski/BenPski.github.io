---
title: Classical Elastica
---

A long, long time ago some old famous guy posed the problem: what is the shape of a slender rod stuck in the ground went bent by a hanging weight? This problem is the origin of the elastica, a model of slender rods that undergoes large deformations. The general elastica modeling procedure is a useful place to start when thinking about more complicated rod models and continuum mechanics in general, though given some of the assumptions it is necessary to look at continuum mechanics more deeply to really get a feel for it.

SOME IMAGE

For the classical elastica we start by considering the angle, $\theta$, for every point along the rod and the positions $x$ and $y$. I denote the location along the rod with $s\in[0,L]$ where $L$ is the length of the rod. So, at every point along the body we have an angle, $\theta(s)$, relative to the global frame and an $x(s)$ and $y(s)$ position. Considering that there is no change in length for the rod we can define:

$$
x' = -\sin(\theta) \\
y' = \cos(\theta)
$$
where $'$ denotes the derivative with respect to $s$. This is all the kinematics we need for the elastica.

To balance the loads on the elastica we have two loads: the internal bending stiffness, and the moment due to the hanging weight. For the internal bending stiffness we have the moment $M = K\theta'$ where $K$ is the bending stiffness and $\theta'$ is the bending curvature, typically $K = EI$ where $E$ is the Young's modulus and $I$ is the second moment of area for the cross sections of the rod. The moment due to the hanging weight is $M = (x(s)-x(L))mg$ where $m$ is the mass of the hanging weight and $g$ is the gravitational acceleration. Setting these equal to each other gives:

$$
K\theta' = (x(s)-x(L))mg
$$ 

Due to the dependence on $x(L)$ this form is slightly inconvenient to work with as it requires information that is not local; however we can take the derivative to get:

$$
K\theta'' = -mg\sin(\theta)
$$

Grouping together the coefficients into a single coefficient $\theta'' = -\alpha \sin(\theta)$, creating a dimensionless spatial position $\sigma = s/L$ and reusing $'$ to mean derivative with respect to $\sigma$ we have $\theta'' = -\beta \sin(\theta)$ with $\beta = L^2\alpha$. 

The interesting feature for this equation is that it is exactly the same as a pendulum without damping or applied torques. So, we can interpret the shape of the elastica as the trace of the angle for a pendulum over some finite time horizon, where $L$ acts as the analog to the time horizon. This is mostly an interesting coincidence rather than a useful tool though.

How do we solve for $\theta(s)$ of the rod? The punchline is that it is an elliptic integral that has to be computed numerically, but we need some tricks to get it into the desired form. The first step is to integrate both sides over $d\theta$.

$$
\int \theta'' d\theta = -\beta\cos(\theta) + C
$$ 


For the left hand side we can do some manipulation. First expand $d\theta$ to $\theta'd\sigma$ and then with some cleverness we can note that:

$$
\theta''\theta' = \frac{1}{2}\frac{d}{d\sigma} (\theta'^2)
$$

This allows for rearranging the left hand side to:

$$
\int \theta'' d\theta = \frac{1}{2}\int \frac{d}{d\sigma} (\theta')^2 d\sigma = \frac{1}{2}\theta'^2
$$

To solve for the constant we know that at the tip of the rod will take on some angle $\theta(L) = \phi$ and that there is no moment at the tip and therefore $\theta' = 0$ which leaves:

$$
\theta'^2 = -2\beta(\cos(\theta) - \cos(\phi)) 
$$

Now we can get a first order differential equation which can be integrated to get $\theta$. In evaluating the square root, the sign determines which side the rod bends towards so it is preference which to pick or specified by the problem, here I choose the positive root.

$$
\theta' = \sqrt{2\beta}\sqrt{\cos(\phi)-\cos(\theta)}
$$ 

Separating differentials and integrate gives:

$$
\int d\sigma = \int \frac{d\theta}{\sqrt{2\beta}\sqrt{\cos(\phi)-\cos(\theta)}}
$$

The left hand side is simple and we can rearrange the right hand side a bit.

$$
1 = \frac{1}{\sqrt{2\beta}}\int \frac{d\theta}{\sqrt{\cos(\phi)-\cos(\theta)}}
$$

Looking ahead a bit, we know that the solution is based on the elliptic integral of the first kind so we want the term in the integral to look like $\frac{1}{\sqrt{1-m*sin(x)^2}}. We can shift toward this form using $cos(x) = 1-2\sin(x/2)^2$ and get:

$$
1 = \frac{1}{\sqrt{\beta}} \int\frac{d\theta}{\sqrt{\sin(\phi/2)^2-\sin(\theta/2)^2}}
$$

To get into the desired form define a new angle $2\gamma = \theta$ and do some rearranging to get:

$$
1 = \frac{1}{A}\int_0^{\phi/2}\frac{d\gamma}{1-B\sin(\gamma)^2}
$$
where $A = \frac{1}{\sqrt{\beta}}\sin(\phi/2)$ and $B = \frac{1}{\sin(\phi/2)^2}$. Which is the form of the elliptic integral of the first kind. There are different forms and notations used for elliptic integrals, but I don't want to manipulate them anymore.

# Solving

To actually solve this numerically you can either solve the elliptic equation or just use the ODE definition and integrate that in standard ways. I think the most straightforward way is to solve the ODE as a boundary value problem (BVP), at the base we know $\theta(0) = 0$, at the tip we know $\theta(L)' = 0$, and we have a second order differential equation $\theta'' = \alpha\sin(\theta)$ describing the system. That is an easy way to pose the problem, but BVPs can be slightly tricky to actually solve due to most numerical processes solving initial value problems (IVP). There are many ways to do this (pseudospectral, galerkin, shooting, etc.) and here I'll show how to use a shooting method. 

For using a shooting method we use an IVP solver to integrate the ODEs using a guessed value for the unknown initial conditions,check that the known boundary conditions at the other side of the domain are satisfied, if they aren't update the guess and repeat. This is essentially an IVP solver wrapped in a root-finding method.

Since the elastica is a scalar valued problem it is easy enough to implement the solving procedure by hand in any language; however, if it were more complicated (especially in the equation solving/root finding) I'd recommend established libraries or software (though I know that it is always worth trying it once so you can see how much better someone else's software is).

For this the simplest numerical implementation uses what is known as forward Euler integration and Newton's method for root solving. The forward Euler integration is the simplest numerical integrator there is, if we have a system $\dot{x} = f(x,t)$ we approximate the derivative as $\dot{x} \approx \frac{x_{i+1}-x_i}{\Delta t}$ where $x_{i}$ is the i-th discrete point of $x$ and $\Delta t$ is the discrete time step then evaluating $f(x_i,t)$ we get:

$$
x_{i+1} = x_i + \Delta tf(x_i,t)
$$ 

So, starting from some initial conditions, $x_0$, we can integrate over the desired domain of $t$. Now this only poses the problem as a first-order ODE, but all ODEs can be reduced to first-order systems by variable substitution. For the elastica problem we have:

$$
\theta'' = -\alpha\sin(\theta)
$$

To rewrite this into first-order form we can substitute $x_0$ for $\theta$ and $\x_1$ for $\theta'$ which will give:

$$
x_0' = x_1 \\
x_1' = -\alpha\sin(x_0)
$$
which is now in first-order form. Allowing us to write the use the integrator for the elastica problem.

Now root-finding has many techniques and huge amounts of work going into it, but the simplest method is general is Newton's method. Newton's method goes:

$$
x_{n+1} = x_n - \frac{f(x_n)}{f'(x_n)}
$$ 

where $f'$ is the derivative of $f$. Given a close enough initial guess this should converge to the root of $f$. An issue arises when $f'$ is unavailable or inconvenient to compute. Several methods are available to deal with this, two simple methods are approximate the derivatives by finite differences and the secant method. The secant method approximates the derivative by the last two points visited while finite differences approximate the derivative by small perturbations in the input. Here I'm going to use finite differences to get better derivative information.

The finite difference approximation is:
$$
f'(x_n) = (f(x_n + \epsilon) - f(x_n))/\epsilon
$$
where $\epsilon is some small value (e.g., $1\times10^{-5}). Substituting this into the Newton iteration we get:

$$
x_{n+1} = x_n - \epsilon\frac{f(x_n)}{f(x_n+\epsilon) - f(x_n)}
$$

With the forward Euler integrator and the Newton method the elastica problem can be solved by guessing $\theta'(0)$, integrating the ODE with the Euler method, check the boundary condition $\theta(L)' = 0$, and use Newton's method to update the guess. This makes $f$ in Newton's method the integrated value for $\theta(L)'$.

An implementation is shown below to play with. Just kidding, not sure how to do that right now.


# Extensions

The original elastica problem can be generalized by considering arbitrary loading cases rather than just a hanging mass and it provides a simple prototype to analyze for rods. By having only bending stiffness in a single plane keeps the physics pretty simple, but it captures the main phenomena of most problems. The modeling and solving of this is found in other notes.