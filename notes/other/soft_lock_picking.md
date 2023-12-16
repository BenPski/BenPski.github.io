---
title: "Soft Lock Picking: The Worst Bug Catcher Battle"
---

Doing some analysis for the scenario in [this video](https://www.youtube.com/watch?v=3DF8XOhsFyg).

The situation is you have a Weezing at level 100 that just knows Explosion and
the only thing you are able to do is fight a trainer with a level 9 Weedle.

You need to be able to win the battle to escape the situation. So the question
is: how likely are you to win the battle?

## Mechanics

As talked about in the video the only way to escape the battle is to win without
ever using Explosion. To do that you'd need to rely on the disobedience and
struggle mechanics.

[Struggle](https://bulbapedia.bulbagarden.net/wiki/Struggle_(move)) is pretty
straightforward, once all of a pokemon's moves run out of PP
they start using the move struggle. Struggle is a 50 base power move and in 
Generation 3 (the relevant generation to the video) does 1/4 recoil to the user.

For [disobedience](https://bulbapedia.bulbagarden.net/wiki/Obedience#Generation_III_and_IV)
it is a bit more complicated, but in Generation 3 the gist is
if a pokemon has a chance to disobey it will pick between:

- using the instructed move
- going to sleep
- doing confusion damage to itself
- doing nothing

So what is being taken advantage of in this battle is Weezing disobeying in such
a way that it never attacks and Weedle uses all of its moves until is Struggles
itself to death.

It is implicitly relevant everywhere, but computing [stats](https://bulbapedia.bulbagarden.net/wiki/Stat#Determination_of_stats)
and [damage](https://bulbapedia.bulbagarden.net/wiki/Damage#Generation_III) are also very important to the whole situation.

### Important Equations and Calculations

Disobedience:

```
R1 = choose(0, 255)
oCheck = (level + oCap) * R1/256
if oCheck >= oCap:
    R2 = choose(0, 255)
    dAction = (level + oCap)*R2/256
    if dAction < oCap:
        pick_different_move
    else:
        R3 = choose(0, 255)
        if R3 < (level - oCap):
            sleep
        if R3 < 2 * (level - oCap):
            hit_self
        else:
            do_nothing
else:
    do_instructed
```

In the considered case `level = 100`, `oCap = 10`, and picking a different move 
amounts to doing nothing since Weezing only knows one move.

Stats:

$$
\begin{gather}
HP = \lfloor\frac{(2 * Base + IV + \lfloor\frac{EV}{4}\rfloor) * Level}{100}\rfloor + Level + 10 \\
Stat = \lfloor (\lfloor \frac{(2 * Base + IV + \lfloor \frac{EV}{4} \rfloor)*Level}{100} \rfloor + 5) * Nature \rfloor
\end{gather}
$$

$IV$ ranges from 0 to 31, $EV$ ranges from 0 to 252, and $Nature$ is 0.9, 1, or 1.1.

Damage:

$$
\begin{equation}
((\frac{(\frac{2*Level}{5}+2)*Power * \frac{Attack}{Defense}}{50})*M1 + 2) * M2 * random
\end{equation}
$$

$M1$ is a collection of multipliers, $M2$ is another collection of multipliers,
and $random$ is a value between 0.85 and 1. In this particular case $M1$ is 1
and $M2$ is $M2 = Critical * STAB * Type1 * Type2$ (whether it was a critical
hit, if the move has same type attack bonus, and resistance/weakness calcs).

## Simplified (and inaccurate) Solution

To restate the situation again.

Weezing Lv 100:
- Explosion (5 PP)

vs

Weedle Lv 9:
- Poison Sting (35 PP)
- String Shot (40 PP)

Something pretty obvious is that Weezing's Explosion will knock out Weedle, but
lets do the calculations anyways as some examples of what is going on.

What are Weedle's stats? The relevant ones are HP and defense in this case since
Explosion is a physical move.

Weedle's base HP is 40 and base defense is 30. We do happen to know the actual
stats all trainer pokemon have [spreadsheet](https://docs.google.com/spreadsheets/d/1frqW2CeHop4o0NP6Ja_TAAPPkGIrvxkeQJBfyxFggyk/edit?usp=sharing],
but lets pretend we don't.

Pretty easy to tell that the lowest stat is when there $IV=0$, $EV=0$, $Nature=0.9$
and the highest stat when $IV=31$, $EV=252$, and $Nature=1.1$. So, Weedle's
stat range is:

- HP: 26 - 34
- Attack: 9 - 20
- Defense: 9 - 19
- Special Attack: 7 - 18
- Special Defense: 7 - 18
- Speed: 12 - 24

Which falls in line with the spreadsheet

The quick python code for this:

```python
>>> hp = lambda base, iv, ev, level: ( ((2*base+iv+(ev//4))*level)// 100) + level + 10
>>> stat = lambda base, iv, ev, level, nature: math.floor(( ((2*base+iv+(ev//4))*level)// 100 + 5) * nature)
>>> hp_range = lambda base, level: (hp(base, 0, 0, level), hp(base, 31, 252, level))
>>> stat_range = lambda base, level: (stat(base, 0, 0, level, 0.9), stat(base, 31, 252, level, 1.1))
>>> pokemon_ranges = lambda level, hp, attack, defense, sp_attack, sp_defense, speed: [
... hp_range(hp, level)] + [stat_range(val, level) for val in [attack, defense, sp_attack, sp_defense, speed]]
>>> pokemon_ranges(9, 40, 35, 30, 20, 20, 50)
[(26, 34), (9, 20), (9, 19), (7, 18), (7, 18), (12, 24)]
```

Weezing's ranges are then:

- HP: 240 - 334
- Attack: 166 - 306
- Defense: 220 - 372
- Special Attack: 157 - 295
- Special Defense: 130 - 262
- Speed: 112 - 240

With these what is the range of damage Weezing's Explosion will deal to Weedle?
The minimum is going to be the highest defense Weedle, lowest attack Weezing,
with a low random value, and no critical hit.

```python
>>> damage = lambda level, power, attack, defense, mult, r: math.floor(((((2 * level // 5 + 2) * power * attack // defense) // 50) + 2) * mult * r)
>>> damage(100, 250, 166, 19, 1, 0.85)
1560
```

The minimum damage is 1560 HP, safe to say Weedle is getting knocked out.

This is the gist of the calculations that would be done in the background, the
extra though is the expected values of things like damage. There are 2 random
values that influence the damage done, critical hits and the random multiplier.
For this we can still represent things as ranges, but the problem is we can't
actually hit every value in the range if we just say the minimum and maximum, so
a range is misleading. Simple example is the gap between a max random roll
without a critical and a minimum roll with a critical can be quite large (in the
above case it is 1836 vs 3121 damage). Representing every possible value is 
one alternative, but that is often overly tedious especially for high-level 
analysis. That is were the expected value or weighted average comes in, it gives
a single representitive value for something that could take on many values.

Back to the actual problem: how likely is it that Weezing can beat the Weedle?

To simplify things lets say that Weezing can't actually get knocked out by 
anything other than Explosion (aka has infinite HP). In practice Weezing can get
knocked out by self-inflicted damage and the combined damage from Weedle's Poison
Sting and Struggle, but simplifying the problem like this will make the first pass
of the analysis easier.

So what do we want to know? We want Weedle to use all of it's moves until it
uses Struggle enough times to do enough recoil damage to knock itself out. This
will tell us how many turns Weezing needs to not use Explosion. After that we can
compute how likely it is for Weezing to not use Explosion for that many turns.

To start Weedle has a total of 40 + 35 = 75 PP, so the battle will last 75 + the
number of turns Weedle takes to Struggle.

To determine the amount of damage Struggle does to Weedle we need to know how 
much it does to Weezing since it does 1/4 of whatever it did to Weezing back to
itself.

Since this is an exercise in worst cases let Weezing's Defense be maxed out and
Weedle's Attack be the minimum. The damage is 2 HP, even with a critical hit it
is 4 damage. In the best case it is also a max of 4 damage. That means Struggle
will always do 1 damage to Weedle since recoil always does at least 1 damage.

So, the number of turns the battle needs to last is 75 + Weedle's HP. Weedle's
HP is 26 - 34, so we can say the worst case is 109 turns of not using Explosion.
According to in-game data it is 26 HP so it is really 101 turns.

For Weezing we need to know what will happen on any given turn. Every turn we 
are forced to select Explosion and then we roll the dice on disobedience. The 
things that can happen for disobedience are:

- use the move
- pick a different move (do nothing in this case)
- go to sleep
- hit itself (do nothing in this simplified case)
- do nothing

The chances for these particular things are mostly based around random rolls
between 0 and 255. The check is

$$
\frac{(100 + 10)*r}{256} \geq 10
$$

or 

$$
r \geq \frac{2560}{110}
$$

for integers that is $r \geq 23$ which is a $\frac{256-24}{256} = \frac{29}{32}$
chance of happening.

So, this amounts to:

- $\frac{29}{32}$ disobeys
  - $\frac{3}{32}$ uses a different move (does nothing)
  - $\frac{29}{32}$ does something else
    - $\frac{90}{256}$ goes to sleep
    - $\frac{90}{256}$ damages itself (does nothing)
    - $\frac{256-180}{256}$ does nothing
- $\frac{3}{32}$ uses explosion

or in the considered case

- $\frac{3}{32}$ uses explosion
- $\frac{29}{32}\frac{29}{32}\frac{45}{128}$ goes to sleep
- $\frac{29}{32}(\frac{3}{32} + \frac{29}{32}(\frac{45}{128} + \frac{19}{64}))$ does nothing

The interesting thing is going to sleep because in Generation 3 a pokemon goes 
to sleep for 1 - 5 turns and because if you know what sleep state the pokemon is
in you know the transition.

We can choose to model the state of Weezing like:

- Alive
- Sleep 1
- Sleep 2
- Sleep 3
- Sleep 4
- Sleep 5
- Dead

Then we know the chance to transition between any given state on a given turn.

- For the Dead state it will always transition to the Dead state
- For a Sleep state it will always transition to the next lowest sleep state
except for Sleep 1 which transitions to Alive
- Alive then has a chance to move to any other state according to the calculated
probabilities. Explosion -> Dead, do nothing -> Alive, goes to sleep -> 20%
chance to go to any Sleep state

Using this model it is perfect for a Markov Chain. To use the Markov Chain we 
setup the transition matrix by putting the probabilites of moving from one state
to another such that it goes row -> column. Then exponentiate the matrix the 
number of iterations we care about (the number of turns in the battle) and extract
the state we are interested in by multiplying by a vector representing the state.

Since the matrix is small enough I'll write it out:

$$
T = \begin{bmatrix}
A & S & S & S & S & S & D \\
1 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 1 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 1 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 1 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 1 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 1 \\
\end{bmatrix}
$$

where $D = \frac{3}{32}$, $S = \frac{1}{5}(\frac{29}{32})^{2}\frac{45}{128}$, 
$A =\frac{29}{32}(\frac{3}{32} + \frac{29}{32}(\frac{45}{128} + \frac{19}{64}))$.

Then we can compute the likelihood of surving 109 turns by doing $T^{109}$.

Using $a = [1,0,0,0,0,0]$ and $d = [0,0,0,0,0,0,1]$ to represent the alive and
dead state to extract the value of going from alive to dead. We get

```python
>>> a*T**109*d.T
matrix([[0.99532741]])
```

a 99.5% chance to lose any given battle or a less than 0.5% chance to win.

## More Accurate Solution

As alluded to before, Weezing does take damage during the battle through
self-inflicted damage and damage from Weedle's Poison Sting and Struggle, so the
inifinite health assumption is misleading as Weezing could faint from not using
Explosion, but how does this effect the result?

A caveat we want to consider here is that 

To start let's see what the total damage Weedle will do. We know that it will
do 35 Poison Stings and 34 Struggles. The base power of Poison Sting is 15 and
$M2=1.5*0.5*Critical$ because it gets STAB and it is resisted by Weezing.

Doing some brute force iterations it doesn't matter if it is the weakest Weedle
vs the strongest Weezing or the strongest Weedle vs the strongest Weezing, the
expected value for Poison Sting damage is always 1.06640625. Which amounts to
37.3 damage on average. For Struggle same deal the expected damage is always
1.1875 which amounts to a total of 77.7 damage from all of Weedle's attacks.

### A wild anomally appears

Actually, checking this against an existing damage calculator my calculations
don't match. Luckily I happened to have an Emerald save around with a high level
pokemon to test which is accurate. I have a Rayquaza at level 70 and can go to 
a route that has low level Poochyena. Poochyena will always use Tackle and 
Rayquaza can just use Rest. According to Pokemon Showdown's calculator a crit
can do 5 or 6 damage, while the calculation I was using will max out at 4. So,
hanging around for a crit and tah-dah a crit and it does 5 damage, the above 
calculation is wrong, but why?

Well, looking through the code I see that if the section of the equation
$\frac{(\frac{2 * Level}{5} + 2) * Power * \frac{A}{D}}{50}$ has the extra 
condition that it must be at least one for physical moves. Updating the function
to be:

```python
>>> damage = lambda level, power, attack, defense, mult, r: max(1,
...math.floor((max(1,((((((2 * level) // 5) + 2) * power * attack) // defense) // 50)) + 2) * mult * r))
```

and now the computations are matching with Pokemon Showdown it seems.

This doesn't effect the recoil calculations from before since the recoil never
exceeds 1 damage because it rounds down. Confirmed in game by getting a high level
pokemon to use struggle to knock out a pokemon with an HP stat that isn't divisble
by 4 and seeing which way it rounds. This will change the previous Poison Sting
and Struggle damage though

### Back to it

With the updated calculation what is the actual expected amount of damage Weedle
will deal? The total is a smidge over 118 damage which is an honestly unexpected
amount, but clearly shows why the first approximation was optomistic.

This means Weezing has somewhere around 122-216 HP to spare for damaging itself
across all 109 turns.

So, what is confusion damage? It is a 40 base power move that uses the confused
Pokemon's attack and defense in the calculations and it can't crit. In the spirit
of the Soft Lock Picking series we want this to be the worst case scenario. That
means low HP, low defense, and high attack. The expected value for damage in this
case is 44 damage and using 122 spare HP that means Weezing can hit itself 3 times
before knocking itself out.

The updated disobedience considerations are:

- $\frac{3}{32}$ uses explosion
- $\frac{29}{32}\frac{29}{32}\frac{45}{128}$ goes to sleep
- $\frac{29}{32}\frac{29}{32}\frac{45}{128}$ hits itself
- $\frac{29}{32}(\frac{3}{32} + \frac{29}{32}\frac{19}{64})$ does nothing

For the state of Weezing we now need to know how many hits it has taken. Alive
needs to be distinguished between by using number of hits it has taken and so
does Sleep. Dead is still Dead though, there is just a new transition to it.
Since there are 3 hits that needs to be added to the Alive and 5 Sleep states 
that amounts to a total of 19 states which is too much to be writing out by hand
in matrix form. Though the description is:

```
transition Dead Dead = 1
transition (Alive, 2) Dead = E + H
transition (Alive, _) Dead = E
transition (Alive, x) (Alive, x+1) = H
transition (Alive, x) (Sleep n, x) = S
transition (Alive, x) (Alive, x) = A
transition (Sleep 1, x) (Alive, x) = 1
transition (Sleep n, x) (Sleep n-1, x) = 1
transition _ _ = 0
```

Implementing this through a dictionary and then converting to a matrix isn't too
bad. A quickly thrown together implementation is:

```python
import numpy as np

orig_states = ['Alive'] + [('Sleep', i) for i in [1,2,3,4,5]]
states = [(s, h) for s in orig_states for h in [0, 1, 2]]+ ['Dead']

E = 3/32
S = 1/5*29/32*29/32*45/128
H = 29/32*29/32*45/128
A = 29/32*(3/32 + 29/32*19/64)

def transition_dict():
    d = {}

    # initialize and simple cases
    d['Dead'] = {}
    for hits in [0,1,2]:
        d[('Alive', hits)] = {}
        d[('Alive', hits)]['Dead'] = E
        d[('Alive', hits)][('Alive', hits)] = A
        for sleep_turns in [1,2,3,4,5]:
            d[(('Sleep', sleep_turns), hits)] = {}
            d[('Alive', hits)][(('Sleep', sleep_turns), hits)] = S

    # hit transitions
    for hits in [0, 1]:
        d[('Alive', hits)][('Alive', hits + 1)] = H

    # sleep transitions
    for hits in [0, 1, 2]:
        for sleep_turns in [2,3,4,5]:
            d[(('Sleep', sleep_turns), hits)][(('Sleep', sleep_turns - 1), hits)] = 1

    # special cases
    d['Dead']['Dead'] = 1
    d[('Alive', 2)]['Dead'] = E + H
    for hits in [0, 1, 2]:
        d[(('Sleep', 1), hits)][('Alive', hits)] = 1

    return d

def create_matrix():
    arr = [[0 for i in range(len(states))] for j in range(len(states))]
    d = transition_dict()
    for (i, state1) in enumerate(states):
        for (j, state2) in enumerate(states):
            if state1 in d and state2 in d[state1]:
                arr[i][j] = d[state1][state2]
            else:
                arr[i][j] = 0
    print(arr)
    return np.matrix(arr)
```

The resulting probability of losing is:

```
>>> a * T**109 * d.T
matrix([[0.99999973]])
```

## Results

So, in the worst case scenario where the Weedle has the max HP and the Weezing
has the max attack, minimum defense, and miminum HP roughly 3 in 10,000,000 
battles you will win.

With the actual HP Weedle has in game the odds increase ever so slightly to

```
>>> a * T**101 * d.T
matrix([[0.999999]])
```

which is a 1 in 1,000,000 chance to win.

## Extensions

There are some clear ways to make this situation worse in uninteresting ways
like giving Weezing Selfdestruct or picking a pokemon that does more damage with
confusion hits and takes more damage from Weedle. The more interesting things
though are:

- finding an optimal level, the obedience and damage potentially form an
interesting non-linear relationship making for a worse situation
- being more general with the results, I eventually picked a specific pokemon
to analyze to avoid just enumerating a bunch of calculations. My guess is there
is someway of being more sophisticated in the analysis so that you can consider
a more general case and not just have to do a bunch of enumeration.

I'm not going to be working on that now though.
