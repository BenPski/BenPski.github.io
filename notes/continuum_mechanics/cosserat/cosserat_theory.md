---
title: Cosserat Theory
---

In continuum mechanics there are several different distinctions for modeling approaches depending on the base assumptions going into them. For example, generally there is a distinction between finite strains and infinitesimal strains where the latter is simpler and generally the point of introduction for solid mechanics. There are also what are known as microstructure theories. In these approaches rather than treating the fundamental element of a body as a particle they are infinitesimal bodies with extra structure than just a position. For Cosserat theory it is a finite strain theory that treats the microstructure as a rigid body, so it has both position and orientation which is why it can be referred to as a micropolar theory. Cosserat theory, as far as I'm aware, is the earliest microstructural theory and the introduction to the idea of the directed curve in continuum mechanics (though this may belong to Kirchhoff rod theory due to their similarities). Since, Cosserat theory is the approach to modeling solids that I'm familiar with I will be writing about the basic ideas, though much of the notation comes from a robotics approach (e.g., Screw theory) so for people more familiar with standard continuum mechanics notation and terminology (e.g., tensor stuff) this may be a bit odd.

# Kinematics

In Cosserat theory every point in a body is described by a position and orientation relative to some fixed frame. This means that every point in the body can be described by the Special Euclidean group ($SE(3)$) which is also the description of generalized rigid body displacements commonly used in robotics. So, relative to a fixed frame we have a rotation, $R\in SO(3)$, and a position, $p\in\mathbb{R}^3$, which can be joined into a homogeneous transformation matrix, $g\in SE(3)$:
$$
g = \begin{bmatrix} R & p \\ 0 & 1 \end{bmatrix}
$$

Then, we define however many necessary spatial parameters, $s$, to locate any point in the body uniquely. In the case of a rod we have one, a surface has two, and so on. These will typically be defined on some bounded interval. Then for every point in the body we have $g(s_1,s_2,s_3)$ to describe the configuration of the body. At every point for the spatial parameters we can imagine an orthonormal frame being attached to the body at that point, these are generally called the directors, the director frame, or can be seen as the body frame. The directors are what allow us to define the position and orientation of a point relative to the fixed frame.

Now, we notice that $SE(3)$ is a Lie group and can therefore evaluate the derivative with respect to space as:
\begin{equation}
\frac{\partial}{\partial s_i} g = g\hat{\xi}_i
\end{equation}
where $\hat{\xi}_i\in se(3)$ is the Lie algebra element of $se(3)$ along the i-th spatial parameter. Here $\hat{.}$ represents the isomorphism from $\mathbb{R}^6$ to $se(3)$ as all Lie algebras have both a vector and matrix representation (not quite, there are more abstract representations of Lie groups and algebras). 
\begin{gather}
\xi = \begin{bmatrix} \omega \\ \nu \end{bmatrix} = \begin{bmatrix} \omega_1 \\ \omega_2 \\ \omega_3 \\ \nu_1 \\ \nu_2 \\ \nu_3 \end{bmatrix} \\
\hat{\xi} = \begin{bmatrix} \hat{\omega} & \nu \\ 0 & 1 \end{bmatrix} \\ 
\end{gather}
where $\hat{\omega}$ is overloading the $\hat{.}$ operator for $so(3)$. $so(3)$'s operator is then:
\begin{equation}
\hat{\omega} = \begin{bmatrix} 0 & -\omega_3 & \omega_2 \\ \omega_3 & 0 & -\omega_1 \\ -\omega_2 & \omega_1 & 0 \end{bmatrix} \\
\end{equation}

Borrowing some terminology from Screw theory, we call the Lie group elements the configuration or displacement and the Lie algebra elements the twists. In Screw theory twist refers specifically to a generalized velocity (both angular and linear combined); however, we now have twists not just defined by the time derivative so they'll be referred to as spatial and temporal twists. With the mention of the temporal twist we also have:
\begin{equation}
\frac{\partial}{\partial t} g = g\hat{\eta}
\end{equation}
where $\eta$ is the temporal twist or generalized velocity.

Using the fact that partial derivatives commute we can relate any of the algebras together using:
\begin{equation}
\frac{\partial}{\partial x_i} \xi_j = \frac{\partial}{\partial x_j} \xi_i + ad_{\xi_j} \xi_i
\end{equation}
where $x_i$ is any spatial or time parameter and $\xi_i$ are any of the spatial or temporal twists.

Which is the beginnings of the kinematics, though to proceed with the physics the deformation gradient and strains need to be defined.

One thing to consider is that Lie groups also have derivatives defined as: $\dot{g} = \hat{x}g$. Here we choose the form we did because it means the twists correspond to values in the body frame which is a bit more convenient to work with, I think.    

# Deformation

# Dynamics
