---
title: Partitions
---

A partition is set where we split the set into subsets that do not overlap and 
their union forms the original set.

If we have the set $\{1,2,3\}$ then the possible partitions are:

$$
\begin{gather}
    [\{\{1\},\{2\},\{3\}\}] \\
    [\{\{1,2\},\{3\}\}] \\
    [\{\{1,3\},\{2\}\}] \\
    [\{\{2,3\},\{1\}\}] \\
    [\{\{1,2,3\}\}] \\
\end{gather}
$$

It is also worth noting that a partition is closely related to an equivalence 
relation. Interpreting each element in a part as being equivelent gives rise to
an equivalence relation and given an equivalence relation you can generate the
parts of a partition.

So, how to represent a partition as a data structure? Well the things we know
are that a partition is a set of non-empty sets. The tricky bit is there are
lots of different ways of constructing a partition. If we are given the original
set then we have 4 options that I can think of:

- construct all possible partitions
- construct a canonical partition
- construct a random partition
- construct a partition according to an equivalence relation

The other perspective for making a partition is to start with an emtpy partition
and then start inserting into it. That gives 2 options:

- construct the partition from an already existing grouping of elements and then
start inserting
- always start from an empty partition and then insert according to some
equivalence relation

The fundamental constructor that would be the easiest to work with is to go from
some pre-grouped data to the parition. This should be the most flexible as all
the other interesting constructions can be built from that fairly easily. This 
also eliminates the initial need for some notion of equality.

For the actual implementation of the data need to pick something to be the
collections. Vectors have the nice feature that you don't need any assumptions
about the data you are storing, but if I use actual sets then I get the proper
quality of sets that they only have an particular element once. The set properties
could be maintained by the exposed functions for working with a partition, but
I don't want to bother with that so I'm going to go with the underlying set
implementation.

```rust
struct Partition<A> {
    parts: HashSet<HashSet<A>>
}
```

However, after trying to implement something for this you'll quickly realize
that `HashSet` doesn't implement `Hash` which prevents this from working. So, 
either I make a hashable set or go back to a vector based implementation. Either
way I need to do something and I don't think there is an obvious way to hash
the `HashSet` or that would already exist.

To get at the heart of the reason for hashing being needed and the problem we
need to understand the underlying implementation. I don't know the underlying
implmentation lol, but I do know that the general idea to make things like 
key-value pairs and sets efficient is to use search trees as their backend
implementation. This is because you usually want to ask something like "is `a`
a member of `A`?" and to do that efficiently you don't want to search every
element in your data structure, you want to be able to reduce your search space
and to do that you need to have some sort of ordered structure in the back.
The simplest implementation is the binary search tree and generally it gets more
specialized from there. The problem then arises for a set, how do you establish
order between all sets in a satifactory way? The background assumption on search
trees is that there is a total ordering on the keys or elements, but for sets
that isn't an obvious thing to implement without adding more structure like
being inherently ordered.

Luckily `collections` already implements `BTreeSet` which requires `Ord` so 
it can be hashed.

```rust
struct Partition<A> {
    parts: BTreeSet<BTreeSet<A>>,
}
```

If I didn't want to making these assumptions about the underlying data, I don't
need something high performance and the use cases I'm anticipating are: do
something to every element and do a comparison between a new item and a single
item in the collection. Which can be done with a vector.

## Construction

The construction goes: given a list of lists make the partition. So something 
like: `new([[1,2],[3,4]]) -> {{1,2},{3,4}`. Which seems like a pretty
straightforward translation. The exception is, nothing in the data structure
is preventing a malformed partition so something like: `new([[1,2],[1,2,3]]) ->
{{1,2},{1,2,3}}` in the naive implementation of the constructor. So, need to
implement some check for making sure elements aren't shared between parts. The
result should be something like: `new([[1,2],[1,2,3]]) -> {{1,2},{3}}`. There
isn't a unique way to resolve it (e.g., it could have also been `{{1,2,3}}`, so
I left it as the easiest way I could think to do it.

Implementing the empty partition creation is trivial.

Creating all partitions for an initial set is an interesting challenge. Looking
at it for a while, what I came up with is:

- create all the paritions of a set one smaller than the given set
- mix in the the element that was left out from the previous step into the 
results of the previous step

The mixing in is the interesting part where I think is best shown by an example.

Starting with `[1,2,3]` split into `(1, [2,3])` and get all the partitions of 
`[2,3]`. Doing that by hand we get

- `[[2],[3]]`
- `[[2,3]]`

so all partitions of `[2,3]` are `[[[2],[3]], [[2,3]]]`. Then to mix in the `1`
for each element in the all paritions result do 2 things:

- add the 1 as a singleton set to the partition
- union {1} with each subset

so this looks like:

for `[[2],[3]]`:

- `[[1],[2],[3]]`
- `[[1,2],[3]]`
- `[[2], [1,3]]`

for `[[2,3]]`:

- `[[1],[2,3]]`
- `[[1,2,3]]`

putting these all together the partitions of `[1,2,3]` are:

- `[[1],[2],[3]]`
- `[[1,2],[3]]`
- `[[2],[1,3]]`
- `[[1],[2,3]]`
- `[[1,2,3]]`

This way of generating all the paritions guarantees no overlaps and generates
all the partitions, so I think that is probably a good enough implementation.

## Testing

In general with testing, I don't actually want to be hard coding results that I
expect and would much rather test the essence of things or do some randomized 
testing. The problem with that can be you always need 2+ ways of getting the 
answer or else you are just testing that your implementation is correct with 
your implementation. That is why people hard code results, the person is the 
second way.

The things to get at are things like when generating all partitions we know that
the total number will be the nth Bell number where n is the number of elements
in the original set. So, if the original set is `[1,2,3]` then the total
number of partitions created by the `all_partitions` method should be the
third Bell number. This is an example of my preferred way of testing things,
this property gives two ways to compute the same value (the total number of 
partitions), is easy to do this generically for some value so it can be randomized,
and it lets you capture information about a large/abstract case that you wouldn't
want to write out by hand.

The two other easy checks are when generating all partitions we know there must
always be the partition with only one subset in it (all subsets considered equal)
and the partition with only singleton sets (the equivalence relation is normal
equality).

There is some more granualar testing that could be done with Stirling numbers,
but I think that is not necessary at least for the moment.
