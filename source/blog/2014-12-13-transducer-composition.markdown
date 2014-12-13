---
title: Transducer Composition
tags: clojure
---

My [startup](http://zensight.co) has been building our product in Clojure. It's been awesome, and overall, it's been pretty easy to learn and be productive with, since our team was already in a functional programming mindset. But we're still learning some of the edges. Specifically, today I was trying out a newish feature called [transducers](http://clojure.org/transducers), which allow you to compose transformations on data without having to care much about its "container" type, so long as that container provides a way to reduce itself.

Just playing around with it, I got confused for a bit that my transducers kept composing in the opposite order I expected. Specifically, this (which I'll explain in a second):

```clojure
(defn doubler [x] (* 2 x))

(into [] (comp (map doubler) (map inc)) [1 2 3]) ;=> (3 5 7)

;;vs the ol' fashioned, non-tranducery:

((comp #(map doubler %) #(map inc %)) [1 2 3]) ;=> (4 6 8)
```

It turns out I'd missed that docs mention that explicitly:

> The composed xf transducer will be invoked left-to-right...

It took me a bit to figure out what was happening at all, and when it dawned on me ("oh, it goes the other way!"), I wondered *why the hell does it do that?* I asked about it on the ClojureScript IRC channel, where [David Nolen](https://twitter.com/swannodette) told me to go look at the source. That's a totally fine answer (it's not his job to sit around and write out detailed answers to my questions), but it's of course more useful if there's an explanation written up, hence this post.

I actually didn't look at the source; instead, I took a nap and when I woke up I was pretty confident I knew the answer.

## A quick review of composition

The order of composition obviously matters; `f(g(x))` is not the same of `g(f(x))`.

```clojure
(defn doubler [x] (* 2 x))

((comp doubler inc) 2) ;=> 6, the result of (doubler (inc 2))

((comp inc doubler) 2) ;=> 5, the result (inc (doubler 2))
```

If you want to apply that composition to each element of a sequence, you'd do something like:

```clojure
(map (comp doubler inc) [1 2 3]) ;=> (4 6 8)
```

But perhaps you have a bunch of functions that operate on sequences, and you want to compose *those*. You end up with the uglier, less efficient, and no less correct composition of maps:

```clojure
((comp #(map doubler %) #(map inc %)) [1 2 3]) ;=> (4 6 8)
```

## Transducers, briefly

Transducers manage to compose the same sort of transformations, but do it in a way that doesn't create intermediate sequences (even lazy ones) and for which the transformations themselves are agnostic about what kind of container they're transforming elements from (or into). It does this by defining various transformations (e.g. `map`, `take`, `filter`, etc) in terms of `reduce` and then parameterizing them with the reduce function itself. So `map` in the transducer world doesn't mean "take each element from a sequence and call this function on them and put the results in another sequence". It means "given some way (let's call it foo) of reducing something,  give me a way of reducing things that increments each thing and then reduces it with foo".

You create a transducer by calling one of the standard listy functions without a collection arg, like `(map inc)`. That transducer can be handed to pieces of machinery that know what transducers mean, like the `transduce` function:

```clojure
(transduce (map inc) conj [1 2 3]) ;=> [2 3 4]
(transduce (map inc) + [1 2 3]) ;=> 9
```

What's really neat is that different containery things can implement `reduce` differently without having to define its own specific transformations (or even make you do it differently for your different use cases). For example, you could use some transducers you built to transform a vector, while your async.core channels can use *the same transducers* to transform values pushed through them. That works because those async channels can provide their own definition of reduce, and the transducers only depend on that having the right shape.

OK, so that's a terse introduction, but for more, go watch [the StrangeLoop talk](https://www.youtube.com/watch?v=6mTbuzafcII).

## Reversals

So why does composing transducers mean they get evaluated "backwards" or "inside out"? Well, on reflection, it makes a lot of sense. What transducers really do is *transform reducing functions*, not actual values; they take one reducing function and return another one that works by transforming its values and passing the results to that passed-in reducing function. When you compose them, you're using the function returned by the "inner" transducer as the reduction function for the "outer" transducer. So if I have `(comp (map double) (map inc))`, I'm saying that `(map inc)` provides a reducing function that takes a value, increments it, and feeds into the reducing function it gets passed. I'm then passing *that* reducing function into the doubling tansducer, which returns another reducing function that doubles the values and *then* feeds the answer into the map-incrementing reducer the doubler took as an argument. So double then inc. Instead of bubbling values out like in a simple compose, your building a set of concentric spheres, each capable of taking a value from the outside and pushing it in.

I'll make that more concrete in a moment, but first, note that this inside-outness is a common feature of composed higher order functions that use their arguments as their "outermost" invocation. Compare our original composed maps to these, which also don't use transducers at all:

```clojure
(defn pre-inc [f] #(f (inc %)))
(defn pre-doubler [f] #(f (double %)))

(((comp pre-doubler pre-inc) identity) 2) ;=> 5

(map ((comp pre-doubler pre-inc) identity) [1 2 3]) ;=> (3 5 7), all backwardslike
```

If that makes sense to you, the next part will be easy. One interesting way to make sense of this is to implement a simplified version of transducers. We'll skip a bunch of complications, like stateful transducers, and we won't bother to make the actual reduction polymorphic or add some of the conveniences. But here goes:

```clojure
(defn my-transduce [xform f init coll]
  (let [reducer reduce ;todo: this should depend on the type of coll
        doit (xform f)]
    (reducer doit init coll)))

(defn my-into [to xform from]
  (my-transduce xform conj to from))

(defn my-map [f]
  (fn [rf] ;rf is like conj or +
    (fn [result input]
      (rf result (f input))))) ;this is the inversion that answers the question

(my-into [] (comp (my-map doubler) (my-map inc)) [1 2 3]) ;=> [3,5,7]
```

That's the whole thing. `my-map` returns a transducer, i.e. a function that takes a reducing function and returns a different one. Since it does its transformation and then delegates the actual core reduction work to its argument, the order of composition *from the standpoint of the individual values* is...well, I still say it's backwards. But it makes good sense.
