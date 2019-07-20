---
title: Variational Calculus
---

$$
\newcommand{\der}[2]{\frac{d#1}{d#2}}
\newcommand{\pder}[2]{\frac{\partial#1}{\partial#2}}  
\newcommand{\firstVary}[1]{\der{}{\epsilon} #1 \rvert_{\epsilon=0}}
$$

Variational calculus aims to solve optimization problems by finding the path extremizes the optimization, $\min_q \int_0^T L(q,\dot q) dt$, or finds a stable point with the variation of the objective, $0 = \delta(\int_0^T L(q, \dot q) dt)$. This is a useful tool for posing optimization problems and as a consequence mechanics problems.

From single variable and multivariable calculus we generally know the way to find minima and maxima of functions. An extrema exists where the curve becomes flat or where the derivative is 0. This works for when we try to find a point, such as the minimum potential, but what do you do when trying to find the minimizing function or trajectory? This is what Variational Calculus is about, finding the extrema of functionals rather than functions. 

Functionals are high order functions or functions that map functions to numbers. The most common form of a functional is an integral which can usually be seen as a total cost or total value for a path. In general if an objective is specified it is desired to find the optimal path for that objective which can be stated as:

$$
\min_{q(t)} J = \int_0^T C(q(t)) dt
$$
where $q(t)$ is the trajectory, $J$ is the total cost, $T$ is the time horizon, and $C$ is the local cost. Now it is possible to want to maximize as well, but minimizing is the more common default. 

We can see that $J$ is a functional, given $q(t)$ a function from time to a configuration we compute a numerical value by integrating over some time horizon, $T$. Just like we can extremize a function by finding where the derivative is 0 we want to develop a similar way to find the extremizing function. 

In the function case the idea was to find a point where an infinitely small perturbation doesn't change the value, aka the limit definition of the derivative.

$$
\lim_{\epsilon \rightarrow 0} \frac{f(x+\epsilon) - f(x)}{\epsilon} = 0
$$

Now the limit perturbs a point by an offset to that point, so for a function we should perturb that function by another function and evaluate some sort of limit seems like the intuitive approach.
 
To start with the optimization problem and the trajectory $q$ that should optimize the objective we imagine coming up with another trajectory similar to $q$. We can do so by perturbing $q$ by some new trajectory $\delta q$.

$$
q \rightarrow q + \epsilon\delta q
$$ 
where $\epsilon$ is a scaling factor for the size of the perturbation and $\delta q$ is a trajectory that doesn't change the problem. By doesn't change the problem it means that the new trajectory respects the boundary conditions as the physical system is determined by its physics as well as its boundary conditions. This is quantified as $\delta q(0) = \delta q(T) = 0$. So, now we have a new trajectory that is a potential candidate for the optimal trajectory, but we want to determine what the optimal one is. 

Using the idea that in the limit of a small perturbation the value should not change we can use:

$$
\lim_{\epsilon \rightarrow 0} \frac{J(q+\epsilon\delta q) - J(q)}{\epsilon} = 0
$$ 

This allows us to find the equivalent of a derivative on a function for a functional. This is referred to as the first variation and is like the first derivative. Other higher-order variations can be defined, but usually only the first and occasionally the second are necessary. The first variation can be written as:

$$
\delta(f(x)) = \frac{d}{d\epsilon} f(x+\epsilon\delta x) \rvert_{\epsilon = 0} 
$$
where $\delta()$ stands for the first variation.

So, with an objective defined as a functional applying the first variation and setting it equal to 0 gives a procedure for determining the optimal trajectory for the objective. When necessary the second variation can be used to determine if it is a minima or maxima like a concavity check. 

# Examples

## Shortest distance between two points
For a simple example what is the shortest distance between 2 points? Obviously this should just be a line, but can we prove it?

The objective here would be the length of some function $f$ and we want to minimize it. First then is how do we measure the length of a curve? We can measure the length of a curve by computing its arclength. This is done as:
$$
L = \int_a^b \lVert f'(s) \rVert ds
$$
where $L$ is the length of the curve between points $a$ and $b$ and the integrand is the norm of the function's derivative. 

Since we are trying to find the curve $f$ that minimizes the distance between points $a$ and $b$ the arclength serves as a functional objective which variational calculus ca be applied to. Taking the first variation of $L$ and setting it equal to 0 should give a way to determine the optimal $f$.

$$
\delta(L) = \frac{d}{d\epsilon} \int \lVert f' + \epsilon y' \rVert ds \rvert_{\epsilon = 0}= 0
$$ 
where instead of $\delta f$ I've used $y$ as the perturbing curve because it is a bit clearer. Now evaluating the derivative of the norm can be a bit tricky so wecan rephrase the norm in terms of a summation:

$$
\firstVary{\int_a^b \sqrt{\sum_i (f_i'+\epsilon y_i')^2}ds} = 0
$$
where the subscript $i$ denotes a component of the curve. The derivative is then:

$$
\int_a^b \frac{\sum_i y_i'(f_i' + \epsilon y_i')}{\sqrt{\sum_i (f_i'+\epsilon y_i')^2}}ds\rvert_{\epsilon=0} = 0
$$

Then applying $\epsilon = 0$:

$$
\int_a^b \frac{\sum_i y_i'f_i'}{\sqrt{\sum_i (f_i')^2}}ds = 0
$$

Using integration by parts and the boundary conditions on $y$ to get rid of the derivative of $y$ we get:

$$
\int_a^b \frac{\sum{y_if_i''}}{\lVert f'\rVert} ds = 0
$$ 

So, in order for the integral to always evaluate to 0 for arbitrary $y$ that means each component on $f''$ must be 0:

$$
f_i''=0
$$

This implies the $f_i'$ is a constant and therefore $f_i$ is linear in $s$.
$$
f_i(s) = a_i + b_is
$$

So the shortest distance between two points is a linear function.

## Brachistochrone 

There is fairly well known problem known as the Brachistochrone problem. This asks the question if a particle moves under the force of gravity what is the curve that results in the shortest time between two points. 

So, we can look at this as a bead sliding down a wire described by $f(s)$ without friction. For simplicity we will restrict the curve to being planar which doesn't change the problem as intuitively it seems the solution must be planar as any out of plane motion (zig-zagging) will just slow it down. The curve can then be described in the x-y plane as:

$$
f(s) = \begin{bmatrix} x(s) \\ y(s) \end{bmatrix}
$$

Then the physics say that it is accelerating only due to gravity which will be in the negative y direction. So, we can use energy to determine the behavior. We have the balance between potetial and kinetic energy as:
$$
mgy + \frac{1}{2}mv^2 = 0
$$
where $m$ is the mass, $g$ is the gravitational acceleration, and $v$ is the velocity. This means the velocity is:
$$
v = \sqrt{2g}\sqrt{-y}
$$ 

We then know that the velocity is the rate at with the particle travels along the curve and we have:
$$
v = \der{s}{t} = \der{s}{x}\der{x}{t}
$$

Given that the infinitesimals on the curve form a right triangle we have $ds^2 = dx^2+dy^2$ which allows for the volcity to be stated as:
$$
v = \sqrt{1+y'^2der{x}{t}
$$

Setting the velocities equal we have:
$$
\sqrt{2g}\sqrt{-y} = \sqrt{1+y'^2}\der{x}{t}
$$

Then going back to the objective of the problem, minimizing the total time we have the objective as:

$$
J = \int_0^T dt
$$

Using the velocity equality we can rewrite this as:

$$
J = \frac{1}{\sqrt{2g}}\int \frac{\sqrt{1+y'^2}}{\sqrt{-y}} dx
$$

Now here is where we would typically apply the first variation and set it equal to 0; however, the algebra can get pretty messy in this approach. To avoid this we can look at a more general problem.

If we have the integrand as some function $L(t,q,\dot{q})$ we will get the following condition on $q$:
$$
\pder{L}{q} - \der{}{t}\pder{L}{\dot{q}} = 0
$$
which should remind you of Lagrangian mechanics (too see the derivation look at [Hamilton's Principle](../../mechanics/hamilton-principle.html). However, in the case when there is no explicit dependence on $t$ we can make another similar statement:

$$
L - \dot{q}\pder{L}{\dot{q}} = C
$$
where $C$ is some constant. Using this form will give some nicer algebra and since it is a conclusion from applying the variation we do not have to actually go through that process we can just substitute $L = \frac{\sqrt{1+y'^2}}{\sqrt{-y}}$.

$$
y'(\frac{y'}{\sqrt{-y}\sqrt{1+y'^2}}) - \frac{1+y'^2}{\sqrt{-y}} = C
$$

With some manipulation this becomes:

$$
y(1+y'^2) = C
$$ 

Which happens to be the ODE for the Brachistochrone, several forms for the explicit equation can be found, but the main thing was noticing that the mainpulation can be simplified when looking for a constant rather than stationary solution. 