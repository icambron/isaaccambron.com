---
title: Three things your programming language must have
published: false
---

The huge variety of mature programming languages available now is part of what makes being a programmer so exciting now. That's not because having a large number of viable languages is, per se, so great, but because it gives you choices. Want mutability or immutability? What kind of type system? How much safety? Object-oriented, imperative, or functional? Choices are good, because different problems require different approaches (or multiple approaches, or a hybrid of approaches), and different people and teams have different styles. Even bigger, having a diverse set of tools around allows you to express a diverse set of *ideas*.

But let's set some limits here. There are some basic minimums your programming language needs to support, whatever its underlying philosophy is. Without these things, it's just crippled. It's just deprived of universal tools required to get things done effectively. Before you complain that I'm just being weirdly absolutist ("You just said differences were good!"), recognize that you agree in principle that such minimums exist; for example, you wouldn't consider a language, whatever its basic aesthetic, to be usable if it didn't have an easy way to represent strings. "We suck at text!" is not a valid language design choice. You can disagree with the minimums I set ("I'm just fine without those things, thank you!"), but there's no real failure of stylistic relativism to set this kind of baseline. We needn't worry that someone will build a real programming language without a good way to represent strings, but the things I have in mind here are missing in many widely-used programming languages. And that just sucks.

This post could also be titled "Why I despise Java".

###An easy way to create maps###

Maps are really important. Don't think of them as hashtables, which is an algorithmic data structure for efficiently looking up pieces of information. Think of it as a container of things with names. That sounds like a pretty important feature, right? For reference, here's a baseline, from Javascript:

```js
var beer = {
  brand: "Alltech",
  name: "Kentucky Bourbon Barrel Ale",
  profile: {
    carbonation: "light",
    mouthFeel: "smooth",

  }
}
```

On the other hand, this is horrible:

```java
Map<String, Object> beer = new TreeMap<String, Object>();
thing.put("brand", "Alltech");
thing.put("name", "Kentucky Bourbon Barrel Ale");
```

That's just a really unclear way to represent a bundle of named things. It's pointlessly verbose and hard to read. You have to use an API to create it; it's totally a second-class citizen of your language.

"But that's what structs or classes are for! You lost all that type safety! You lost all that reuse!" Not really. 

```java
class Beer
{
  public String brand;
  public String name;
}

Beer beer new Beer();
beer.brand = "Alltech";
beer.name = "Kentucky Bourbon Barrel";

```

(And if you tell me I need getters and setters, you've made my case for me. So we'll pretend you didn't.) So how is that better? I actually have to define the keys of my object twice, once in the class definition and once when I create the object. Waste. And for the same reason there's no reuse gain; I still have to use "name" and "brand" every time I create an instance. "Use a constructor!" That doesn't fix anything, and now creating my bundle is more work. There's no type safety issue either: we're talking about creating a value. 
